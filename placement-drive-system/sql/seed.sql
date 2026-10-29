USE placement_db;
-- Demo accounts are created via scripts/seed.js so bcrypt hashes are generated safely.
INSERT INTO companies(company_name,website,location,description) VALUES
('Northstar Technologies','https://example.com','Chennai','Product engineering and cloud services'),
('Apex Digital','https://example.org','Bengaluru','Technology consulting and analytics')
ON DUPLICATE KEY UPDATE company_name=VALUES(company_name);
