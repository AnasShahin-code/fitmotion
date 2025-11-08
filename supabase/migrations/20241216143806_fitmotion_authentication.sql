-- Location: supabase/migrations/20241216143806_fitmotion_authentication.sql
-- Schema Analysis: Fresh project with no existing schema  
-- Integration Type: Fresh authentication module implementation
-- Dependencies: pgcrypto extension for password hashing

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- IMPLEMENTING MODULE: Authentication (login, logout, register)

-- 1. User role types for fitness app
CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'member');
CREATE TYPE public.activity_level AS ENUM ('sedentary', 'lightly_active', 'moderately_active', 'very_active', 'extremely_active');
CREATE TYPE public.gender_type AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE public.unit_system AS ENUM ('metric', 'imperial');

-- 2. Critical intermediary table for user profiles
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    
    -- Fitness-specific profile data
    age INTEGER,
    gender public.gender_type,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    activity_level public.activity_level DEFAULT 'moderately_active'::public.activity_level,
    units public.unit_system DEFAULT 'metric'::public.unit_system,
    
    -- Fitness goals and preferences
    daily_calorie_goal INTEGER,
    weekly_workout_goal INTEGER DEFAULT 3,
    preferred_workout_duration INTEGER DEFAULT 30, -- minutes
    
    -- App preferences
    notifications_enabled BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Fitness-specific tables that reference user_profiles
CREATE TABLE public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    workout_type TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    calories_burned INTEGER,
    notes TEXT,
    session_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.fitness_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    goal_type TEXT NOT NULL, -- 'weight_loss', 'muscle_gain', 'endurance', 'strength'
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2) DEFAULT 0,
    target_date DATE,
    is_achieved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Essential Indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_workout_sessions_user_id ON public.workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_date ON public.workout_sessions(session_date);
CREATE INDEX idx_fitness_goals_user_id ON public.fitness_goals(user_id);
CREATE INDEX idx_fitness_goals_type ON public.fitness_goals(goal_type);

-- 5. Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fitness_goals ENABLE ROW LEVEL SECURITY;

-- 6. Functions for user profile management (MUST BE BEFORE RLS POLICIES)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role)
  )
  ON CONFLICT (id) DO UPDATE 
  SET 
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    updated_at = CURRENT_TIMESTAMP;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Error in handle_new_user: %', SQLERRM;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 7. RLS Policies (following safe patterns)

-- User profiles: Users can read and update their own profile
CREATE POLICY "users_read_own_profile"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "users_update_own_profile"
ON public.user_profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Allow inserts during signup (trigger handles this)
CREATE POLICY "users_insert_own_profile"
ON public.user_profiles
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- Workout sessions: Full access to own sessions
CREATE POLICY "users_manage_own_workout_sessions"
ON public.workout_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Fitness goals: Full access to own goals
CREATE POLICY "users_manage_own_fitness_goals"
ON public.fitness_goals
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. Triggers for automation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_fitness_goals_updated_at
  BEFORE UPDATE ON public.fitness_goals
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 9. Mock Data for Testing Authentication
DO $$
DECLARE
    admin_uuid UUID := '11111111-1111-1111-1111-111111111111';
    premium_uuid UUID := '22222222-2222-2222-2222-222222222222';
    member_uuid UUID := '33333333-3333-3333-3333-333333333333';
BEGIN
    -- Delete existing mock users if they exist
    DELETE FROM auth.users WHERE id IN (admin_uuid, premium_uuid, member_uuid);
    
    -- Create auth users with required fields for FitMotion app
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, confirmation_token, email_change_token_new, email_change,
        phone_confirmed_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@fitmotion.test', crypt('admin123', gen_salt('bf')), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, '', '', '', now()),
        (premium_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'trainer@fitmotion.test', crypt('trainer123', gen_salt('bf')), now(), now(), now(),
         '{"full_name": "Premium Trainer", "role": "premium"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, '', '', '', now()),
        (member_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@fitmotion.test', crypt('user123', gen_salt('bf')), now(), now(), now(),
         '{"full_name": "Regular User", "role": "member"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, '', '', '', now())
    ON CONFLICT (id) DO NOTHING;

    -- Create sample workout sessions
    INSERT INTO public.workout_sessions (user_id, workout_type, duration_minutes, calories_burned, notes, session_date)
    VALUES
        (admin_uuid, 'Strength Training', 45, 320, 'Upper body focus with dumbbells', CURRENT_DATE - INTERVAL '1 day'),
        (premium_uuid, 'HIIT Cardio', 30, 380, 'High intensity interval training', CURRENT_DATE - INTERVAL '2 days'),
        (member_uuid, 'Yoga Flow', 60, 180, 'Morning yoga session for flexibility', CURRENT_DATE)
    ON CONFLICT DO NOTHING;

    -- Create sample fitness goals
    INSERT INTO public.fitness_goals (user_id, goal_type, target_value, current_value, target_date)
    VALUES
        (admin_uuid, 'weight_loss', 75.0, 78.5, CURRENT_DATE + INTERVAL '3 months'),
        (premium_uuid, 'muscle_gain', 80.0, 75.2, CURRENT_DATE + INTERVAL '6 months'),
        (member_uuid, 'endurance', 10.0, 5.5, CURRENT_DATE + INTERVAL '2 months')
    ON CONFLICT DO NOTHING;
        
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data error (safe to ignore if re-running): %', SQLERRM;
END $$;

-- 10. Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON public.user_profiles TO authenticated;
GRANT ALL ON public.workout_sessions TO authenticated;
GRANT ALL ON public.fitness_goals TO authenticated;
