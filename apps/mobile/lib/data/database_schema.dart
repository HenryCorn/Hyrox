/// Single source of truth for the SQLite schema.
/// Bump [kDbVersion] and add a migration case in AppDatabase._migrate()
/// whenever you alter a table.
const int kDbVersion = 1;

const String kCreateUserProfile = '''
  CREATE TABLE IF NOT EXISTS user_profile (
    id           TEXT PRIMARY KEY,
    display_name TEXT,
    created_at   INTEGER NOT NULL
  )
''';

const String kCreateFriendships = '''
  CREATE TABLE IF NOT EXISTS friendships (
    id         TEXT PRIMARY KEY,
    user_id    TEXT NOT NULL,
    friend_id  TEXT NOT NULL,
    status     TEXT NOT NULL DEFAULT 'pending',
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_profile(id)
  )
''';

const String kCreateWorkoutRecords = '''
  CREATE TABLE IF NOT EXISTS workout_records (
    id                    TEXT PRIMARY KEY,
    user_id               TEXT NOT NULL,
    routine_name          TEXT NOT NULL,
    completed_at          INTEGER NOT NULL,
    total_duration_ms     INTEGER NOT NULL,
    splits_json           TEXT NOT NULL,
    rox_zone_splits_json  TEXT NOT NULL,
    avg_heart_rate        INTEGER,
    total_calories        REAL,
    FOREIGN KEY (user_id) REFERENCES user_profile(id)
  )
''';

const String kCreateWorkoutIndex = '''
  CREATE INDEX IF NOT EXISTS idx_workout_user_date
    ON workout_records (user_id, completed_at DESC)
''';
