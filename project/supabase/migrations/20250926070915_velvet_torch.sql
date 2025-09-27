-- RezeCoach Database Schema
-- Complete database structure for Telegram Study & Wellness Assistant

CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  telegram_id TEXT UNIQUE NOT NULL,
  name TEXT,
  timezone TEXT DEFAULT 'Asia/Baghdad',
  preferred_tone TEXT DEFAULT 'friendly',
  study_stage TEXT,
  faculty TEXT,
  major TEXT,
  academic_year TEXT,
  daily_reminder_time TEXT DEFAULT '09:00',
  allow_proactive BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subjects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  note TEXT,
  priority INTEGER DEFAULT 3,
  status TEXT DEFAULT 'not_started',
  current_section TEXT DEFAULT NULL,
  last_activity_ts DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE weekly_schedule (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  day_of_week INTEGER NOT NULL, -- 0=Monday, 6=Sunday
  events_json TEXT, -- JSON array of events
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE study_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  subject_id INTEGER,
  start_ts DATETIME NOT NULL,
  end_ts DATETIME,
  summary TEXT,
  score INTEGER, -- 1-10 rating
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (subject_id) REFERENCES subjects (id)
);

CREATE TABLE water_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  date DATE NOT NULL,
  cups INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  tg_file_id TEXT NOT NULL,
  local_path TEXT,
  file_type TEXT,
  extracted_text TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE user_preferences (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  reminder_window_start TEXT DEFAULT '08:00',
  reminder_window_end TEXT DEFAULT '22:00',
  max_proactive_messages_per_day INTEGER DEFAULT 6,
  night_mode_start TEXT DEFAULT '22:30',
  night_mode_end TEXT DEFAULT '06:00',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Activity tracking for adaptive behavior
CREATE TABLE user_activity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  activity_type TEXT NOT NULL, -- 'message_sent', 'command_used', 'session_started', etc.
  activity_data TEXT, -- JSON data
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Proactive message tracking for rate limiting
CREATE TABLE proactive_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  message_type TEXT NOT NULL,
  sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Indexes for better performance
CREATE INDEX idx_users_telegram_id ON users(telegram_id);
CREATE INDEX idx_subjects_user_id ON subjects(user_id);
CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_water_logs_user_date ON water_logs(user_id, date);
CREATE INDEX idx_user_activity_user_timestamp ON user_activity(user_id, timestamp);
CREATE INDEX idx_proactive_messages_user_sent ON proactive_messages(user_id, sent_at);