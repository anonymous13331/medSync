/*
  # MedSync v0.2 Schema Updates

  ## New Tables
  
  ### 1. `vitals`
  Stores vital signs measurements for health analytics
  - `id` (uuid, primary key)
  - `user_id` (uuid, references auth.users)
  - `type` (text) - bp, sugar, temperature, weight, heart_rate, oxygen
  - `value` (decimal) - Primary value
  - `secondary_value` (decimal) - For BP diastolic, etc.
  - `unit` (text) - mmHg, mg/dL, °F, etc.
  - `measured_at` (timestamptz) - When the measurement was taken
  - `notes` (text) - Additional notes
  - `created_at` (timestamptz)

  ## Table Updates
  
  ### emergency_alerts
  - Add `latitude` (decimal) - GPS latitude
  - Add `longitude` (decimal) - GPS longitude  
  - Add `address` (text) - Formatted address

  ### intakes
  - Add `postponed_to` (timestamptz) - When intake is postponed to

  ## Security
  - Enable RLS on vitals table
  - Add policies for authenticated users
*/

-- Create vitals table
CREATE TABLE IF NOT EXISTS vitals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type text NOT NULL CHECK (type IN ('blood_pressure', 'blood_sugar', 'temperature', 'weight', 'heart_rate', 'oxygen_saturation')),
  value decimal NOT NULL,
  secondary_value decimal,
  unit text NOT NULL,
  measured_at timestamptz DEFAULT now() NOT NULL,
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE vitals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own vitals"
  ON vitals FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own vitals"
  ON vitals FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own vitals"
  ON vitals FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own vitals"
  ON vitals FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create indexes for vitals
CREATE INDEX IF NOT EXISTS idx_vitals_user_id ON vitals(user_id);
CREATE INDEX IF NOT EXISTS idx_vitals_type ON vitals(type);
CREATE INDEX IF NOT EXISTS idx_vitals_measured_at ON vitals(measured_at);

-- Add geolocation columns to emergency_alerts
ALTER TABLE emergency_alerts 
ADD COLUMN IF NOT EXISTS latitude decimal,
ADD COLUMN IF NOT EXISTS longitude decimal,
ADD COLUMN IF NOT EXISTS address text DEFAULT '';

-- Add postponed_to column to intakes
ALTER TABLE intakes 
ADD COLUMN IF NOT EXISTS postponed_to timestamptz;

-- Create index for postponed intakes
CREATE INDEX IF NOT EXISTS idx_intakes_postponed_to ON intakes(postponed_to);
