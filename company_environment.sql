--  WEEKLY ASSIGNMENT - 4

/*Introduction
This SQL project is designed to simulate a company environment where
multiple projects, teams, tasks, models, and datasets are managed. It
involves creating structured relational tables and performing complex
queries using CTEs, window functions, joins, and subqueries to gain
insights into project progress, team performance, and data analytics*/

CREATE DATABASE CompanyDB;
USE CompanyDB;

--  Projects Table

CREATE TABLE Projects (
  project_id INT,
  project_name VARCHAR(50),
  start_date DATE,
  end_date DATE,
  budget DECIMAL(10,2)
);

-- insert values to Projects Table

INSERT INTO Projects VALUES
(1, 'AI Chatbot', '2025-01-10', '2025-04-10', 50000.00),
(2, 'E-Commerce', '2025-02-15', '2025-05-15', 40000.00),
(3, 'Finance Tracker', '2025-03-01', '2025-06-30', 60000.00),
(4, 'Smart Home App', '2025-03-10', '2025-07-10', 45000.00),
(5, 'Health Monitor', '2025-04-01', '2025-08-01', 55000.00);

-- Teams Table

CREATE TABLE Teams (
  team_id INT,
  member_name VARCHAR(50),
  role VARCHAR(50),
  email VARCHAR(100),
  phone_no VARCHAR(20)
);

INSERT INTO Teams VALUES
(1, 'Alice', 'Team Lead', 'alice@example.com', '1234567890'),
(2, 'Bob', 'Developer', 'bob@example.com', '1234567891'),
(3, 'Charlie', 'Developer', 'charlie@example.com', '1234567892'),
(4, 'David', 'Tester', 'david@example.com', '1234567893'),
(5, 'Eva', 'Team Lead', 'eva@example.com', '1234567894');

--  Tasks Table

CREATE TABLE Tasks (
  task_id INT,
  project_id INT,
  task_name VARCHAR(100),
  assigned_to INT,
  due_date DATE,
  status VARCHAR(20)
);

INSERT INTO Tasks VALUES
(1, 1, 'Design UI', 2, '2025-08-10', 'Completed'),
(2, 1, 'Build Backend', 3, '2025-08-20', 'Pending'),
(3, 2, 'Database Design', 1, '2025-08-15', 'Completed'),
(4, 2, 'API Integration', 2, '2025-08-30', 'In Progress'),
(5, 3, 'Testing', 4, '2025-08-25', 'Completed');

--  Model_Training Table

CREATE TABLE Model_Training (
  training_id INT,
  project_id INT,
  model_name VARCHAR(100),
  accuracy DECIMAL(5,2),
  training_date DATE
);

INSERT INTO Model_Training VALUES
(1, 1, 'GPT', 90.25, '2025-06-01'),
(2, 1, 'BERT', 89.10, '2025-06-10'),
(3, 2, 'CNN', 92.00, '2025-06-15'),
(4, 3, 'RNN', 87.50, '2025-06-20'),
(5, 5, 'LSTM', 93.80, '2025-07-01');

--  Data_Sets Table

CREATE TABLE Data_Sets (
  dataset_id INT,
  project_id INT,
  dataset_name VARCHAR(100),
  size_gb DECIMAL(5,2),
  last_updated DATE
);

INSERT INTO Data_Sets VALUES
(1, 1, 'ChatLogs', 12.5, CURDATE() - INTERVAL 10 DAY),
(2, 2, 'ProductData', 9.0, CURDATE() - INTERVAL 40 DAY),
(3, 3, 'FinanceData', 15.2, CURDATE() - INTERVAL 5 DAY),
(4, 4, 'SmartData', 8.5, CURDATE() - INTERVAL 20 DAY),
(5, 5, 'HealthData', 11.0, CURDATE() - INTERVAL 3 DAY);

-- 1. Projects with tatal & completed tasks

WITH Task_Counts AS (
  SELECT 
    project_id,
    COUNT(*) AS total_tasks,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_tasks
  FROM Tasks
  GROUP BY project_id
)
SELECT p.project_name, t.total_tasks, t.completed_tasks
FROM Projects p
JOIN Task_Counts t ON p.project_id = t.project_id;

-- 2. Top 2 team members with most tasks

SELECT member_name, total_tasks FROM (
  SELECT tm.member_name, COUNT(t.task_id) AS total_tasks,
         RANK() OVER (ORDER BY COUNT(t.task_id) DESC) AS rnk
  FROM Tasks t
  JOIN Teams tm ON t.assigned_to = tm.team_id
  GROUP BY tm.member_name
) ranked
WHERE rnk <= 2;

-- 3. Tasks with due dates earlier than the project average

SELECT * FROM Tasks t1
WHERE due_date < (
  SELECT AVG(DATEDIFF(t2.due_date, '2025-01-01'))
  FROM Tasks t2
  WHERE t2.project_id = t1.project_id
);

-- 4. Project with the highest budget

SELECT * FROM Projects
WHERE budget = (SELECT MAX(budget) FROM Projects);

-- 5. Percentage of completed tasks per project

SELECT p.project_name,
       ROUND(100.0 * COUNT(CASE WHEN t.status = 'Completed' THEN 1 END) / COUNT(*), 2)
       AS completion_percent
FROM Projects p
JOIN Tasks t ON p.project_id = t.project_id
GROUP BY p.project_name;

-- 6. Number of tasks assigned per person

SELECT task_name, assigned_to,
       COUNT(*) OVER (PARTITION BY assigned_to) AS tasks_by_person
FROM Tasks
ORDER BY assigned_to;

-- 7. Tasks assigned to team leads, not completed, due in 15 days

SELECT t.*
FROM Tasks t
JOIN Teams tm ON t.assigned_to = tm.team_id
WHERE tm.role = 'Team Lead'
  AND t.status != 'Completed'
  AND t.due_date <= CURDATE() + INTERVAL 15 DAY;

-- 8. Projects without any task records

SELECT p.*
FROM Projects p
LEFT JOIN Tasks t ON p.project_id = t.project_id
WHERE t.task_id IS NULL;

-- 9. Best highest accuracy model for each project

SELECT project_id, model_name, accuracy
FROM (
  SELECT *, RANK() OVER (PARTITION BY project_id ORDER BY accuracy DESC) AS rnk
  FROM Model_Training
) ranked
WHERE rnk = 1;

-- 10. Projects with large datasets updated in the last 30 days

SELECT DISTINCT p.*
FROM Projects p
JOIN Data_Sets d ON p.project_id = d.project_id
WHERE d.size_gb > 10 AND d.last_updated >= CURDATE() - INTERVAL 30 DAY;

/* Conclusion
Through this program, we explored how structured SQL queries can be
used to analyze and manage real-world project data effectively. The
queries provided valuable insights into task completion rates, team
contributions, and data utilization, showcasing the power of SQL in
organizational data analysis.*/
