CREATE DATABASE IF NOT EXISTS blogdb;
USE blogdb;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  role ENUM('user', 'author', 'mod', 'admin') NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS blogs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title TEXT NOT NULL,
  author VARCHAR(100) NOT NULL,
  category TEXT,
  is_subscribers_only BOOLEAN DEFAULT FALSE,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER 'readonly'@'%' IDENTIFIED BY 'readonlypassword';
GRANT SELECT ON blogdb.* TO 'readonly'@'%';
FLUSH PRIVILEGES;
