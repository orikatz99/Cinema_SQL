------------------------------Create Tables:-----------------------------------------

CREATE TABLE cinemaTable (
    cinemaID INT NOT NULL,
    Address VARCHAR(100),
    PRIMARY KEY (cinemaID)
); 

CREATE TABLE employeesTable (
    empID INT NOT NULL,
    empFname VARCHAR(50),
    empLname VARCHAR(50),
    Gender VARCHAR(50),
    DateOfBirth DATE,
    CID INT NOT NULL, 
    PRIMARY KEY (empID),
    FOREIGN KEY (CID) REFERENCES cinemaTable(cinemaID)
); 

CREATE TABLE usherTable (
    EID INT NOT NULL,
    assistedCustomer INT,
    FOREIGN KEY (EID) REFERENCES employeesTable(empID)
);

CREATE TABLE ticketSellerTable (
    EID INT NOT NULL, 
    amountOfSales INT,
    FOREIGN KEY (EID) REFERENCES employeesTable(empID)
);

CREATE TABLE hallTable (
    hallID INT NOT NULL,
    numOfRows INT,
    numOfChairs INT,
    CID INT NOT NULL, 
    PRIMARY KEY (hallID),
    FOREIGN KEY (CID) REFERENCES cinemaTable(cinemaID)
); 

CREATE TABLE movieTable (
    movieID INT NOT NULL,
    Mname VARCHAR(50),
    genere VARCHAR(50),
    raiting INT,
    duration INT, -- time in minutes
    CID INT NOT NULL, 
    PRIMARY KEY (movieID),
    FOREIGN KEY (CID) REFERENCES cinemaTable(cinemaID)
); 

CREATE TABLE screeningTable (
    screenID INT NOT NULL,
    date DATE,
    time TIME,
    MID INT NOT NULL, 
    HID INT NOT NULL, 
    PRIMARY KEY (screenID),
    FOREIGN KEY (MID) REFERENCES movieTable(movieID),
    FOREIGN KEY (HID) REFERENCES hallTable(hallID)
); 

CREATE TABLE viewerTable (
    viewerID INT NOT NULL,
    viFname VARCHAR(50),
    viLname VARCHAR(50),
    email VARCHAR(100),
    PRIMARY KEY (viewerID)
);

CREATE TABLE screeningViewerTable (
    SID INT NOT NULL,
    VID INT NOT NULL,
    PRIMARY KEY (SID, VID),
    FOREIGN KEY (SID) REFERENCES screeningTable(screenID),
    FOREIGN KEY (VID) REFERENCES viewerTable(viewerID)
); 

CREATE TABLE ticketTable (
    ticketID INT NOT NULL,
    price INT,
    category VARCHAR(50),
    SID INT NOT NULL, 
    VID INT NOT NULL, 
    PRIMARY KEY (ticketID),
    FOREIGN KEY (SID) REFERENCES screeningTable(screenID),
    FOREIGN KEY (VID) REFERENCES viewerTable(viewerID)
);

------------------------------Insert data:-----------------------------------------

INSERT INTO cinemaTable VALUES
(1,'Mivtza Kadesh 38, Tel Aviv');

INSERT INTO employeesTable VALUES
(1,'Shani','Halali','Female','2001-08-18',1),
(2,'Ori','Katz','Female','1999-07-16',1),
(3,'Shalom','Mendel','Male','1970-01-01',1);

INSERT INTO usherTable VALUES
(1,10),
(2,24);

INSERT INTO ticketSellerTable VALUES
(3,50);

INSERT INTO hallTable VALUES
(10, 12, 120,1),
(11, 6, 60,1),
(12, 12, 120,1);

INSERT INTO movieTable VALUES 
(10,'Frozen','Family',7,102,1),
(20,'Mean Girls','Comedy',8,97,1),
(30,'The princess diaries','Romance',6,115,1),
(40,'Legally blonde','Romance',5,96,1);

INSERT INTO screeningTable VALUES
(1,'2024-09-25', '18:30:00',40,10),
(2,'2024-09-25', '18:30:00',30,12),
(3,'2024-09-25', '21:00:00',40,11),
(4,'2024-09-26', '10:00:00',10,10),
(5,'2024-09-26', '17:00:00',20,12);


INSERT INTO viewerTable VALUES
(111, 'Rotem', 'Cohen', 'rotem@gmail.com'),
(112, 'Ran', 'Tshuva', 'ran@gmail.com'),
(113, 'Lior', 'Avraham', 'Lior@gmail.com'),
(114, 'Shir', 'Cohen', 'shir@gmail.com');

INSERT INTO ScreeningViewerTable VALUES
(1, 111),
(1, 114),
(3, 112),
(4, 114),
(5, 113);

INSERT INTO ticketTable VALUES --(ticketID, price, category, SID, VID)
(1, 40, 'Regular', 1, 111),
(2, 80, 'Special', 1, 114),
(3, 100, 'VIP', 3, 112),
(4, 40, 'Regular', 4, 114),
(5, 80, 'Special', 5, 113);


------------------------------Working with the database:-----------------------------------------

-- Create a function that will be checked by the trigger to ensure there are available seats before buying a ticket
CREATE OR REPLACE FUNCTION check_availability()
RETURNS TRIGGER AS $$
DECLARE
    seats_sold INT;   
    max_seats INT;    

BEGIN
    -- Step 1: Calculate how many tickets have been sold for the current screening 
    SELECT COUNT(*) INTO seats_sold
    FROM ticketTable
    WHERE SID = NEW.SID;   

    -- Step 2: Retrieve the maximum number of seats for the current screening hall
    SELECT numOfChairs INTO max_seats
    FROM hallTable
    WHERE hallID = (SELECT HID FROM screeningTable WHERE screenID = NEW.SID);

    -- Step 3: If the number of tickets sold is greater than or equal to the number of seats in the hall, raise an error
    IF seats_sold >= max_seats THEN
        RAISE EXCEPTION 'No available seats for screening ID: %', NEW.SID; 
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 


-- Create a trigger that checks for available seats before every INSERT into the ticket table
CREATE TRIGGER before_ticket_insert
BEFORE INSERT ON ticketTable  -- The trigger is activated before any INSERT into the ticket table
FOR EACH ROW                  -- The trigger will operate for each row being added
EXECUTE FUNCTION check_availability(); -- Calls the availability check function created earlier


--inserting a new ticket
INSERT INTO ticketTable (ticketID, price, category, SID, VID) VALUES 
(6, 40, 'Regular', 4, 111);

 
SELECT v.viFname, v.viLname, SUM(t.price) AS total_amount
FROM viewerTable v
JOIN ticketTable t ON v.viewerID = t.VID
WHERE v.viFname = 'Rotem' AND v.viLname = 'Cohen'
GROUP BY v.viFname, v.viLname;


ALTER TABLE hallTable
DROP COLUMN numOfRows;


UPDATE screeningTable
SET date = '2024-09-27'
WHERE screenID = 2 OR screenID = 3;


SELECT 
    MT.Mname AS movie_name, 
    ST.date AS screening_date, 
    ST.time AS screening_time, 
    MT.duration AS movie_duration
FROM 
    screeningTable ST
JOIN 
    movieTable MT ON MT.movieID = ST.MID
ORDER BY 
    ST.date,
	ST.time;


--inserting a new Movie
INSERT INTO movieTable (movieID, Mname, Genere, Raiting, Duration, CID) VALUES 
(50, 'Superman', 'Action',4, 143,1);


DELETE FROM movieTable
WHERE raiting <= 5 AND NOT EXISTS (
    SELECT 1 
    FROM screeningTable 
    WHERE MID = movieTable.movieID
);


--Finding the Movie name with the max number of Screening
SELECT MT.Mname, COUNT(ST.screenID) AS screening_count
FROM movieTable MT
JOIN screeningTable ST ON MT.movieID = ST.MID
GROUP BY MT.Mname
ORDER BY screening_count DESC
LIMIT 1;


ALTER TABLE employeesTable
ADD COLUMN salary INT DEFAULT 30;


-- Add empID column to HallTable
ALTER TABLE HallTable
ADD COLUMN empID INT;
-- Update the empID for specific halls
UPDATE HallTable
SET empID = 1
WHERE hallID = 10;
UPDATE HallTable
SET empID = 2
WHERE hallID = 11;
UPDATE HallTable
SET empID = 5
WHERE hallID = 12;
-- Add UNIQUE constraint to usherTable on EID column
ALTER TABLE usherTable
ADD CONSTRAINT unique_EID UNIQUE (EID);
-- Add foreign key constraint to usherTable using EID (which corresponds to empID)
ALTER TABLE HallTable
ADD CONSTRAINT fk_empID
FOREIGN KEY (empID) REFERENCES usherTable(EID);


-- This view displays the usher assigned to each hall.
CREATE VIEW usherForHall_view AS
SELECT 
    HT.hallID AS Hall_ID,
    UT.EID AS Usher_ID,
    ET.empFname AS Usher_First_Name,
    ET.empLname AS Usher_Last_Name
FROM 
    hallTable HT
JOIN 
    usherTable UT ON UT.EID = HT.empID
JOIN 
    employeesTable ET ON ET.empID = UT.EID
ORDER BY 
    HT.hallID;

-- To view the result:
SELECT * FROM usherForHall_view;

-- Create a view that displays ushers and their screening work shift
CREATE VIEW usherScreening_view AS
SELECT
    ET.empFname AS Usher_First_Name,
    ET.empLname AS Usher_Last_Name, 
    HT.hallID AS Hall_ID,
    ST.date AS Screening_date,
    ST.time AS Screening_time,
    ST.screenID AS Screening_ID
FROM 
    ScreeningTable ST
	JOIN hallTable HT ON HT.hallID = ST.HID
	JOIN employeesTable ET ON ET.empid = HT.empid
ORDER BY
    ET.empFname;

SELECT * FROM usherScreening_view;

--inserting a new employees and give them job
INSERT INTO employeesTable VALUES
(4,'Noa','Kirel','Female','2001-04-10',1),
(5,'Omer','Adam','Male','1993-10-22',1);

INSERT INTO ticketSellerTable VALUES
(4,20);

INSERT INTO usherTable VALUES
(5,1);


--Bonus for the best workers
UPDATE employeesTable
SET salary = salary + 10
WHERE empID IN (
    SELECT EID 
    FROM ticketSellerTable
    WHERE amountOfSales > 30
    
    UNION

    SELECT EID
    FROM usherTable
    WHERE assistedCustomer >= 10
);


CREATE VIEW employees_view AS 
SELECT ET.empID, ET.empFname, ET.empLname, ET.Gender, ET.DateOfBirth,
       CASE 
           WHEN TS.EID IS NOT NULL THEN 'Ticket Seller'
           WHEN UT.EID IS NOT NULL THEN 'Usher'
           ELSE 'Unknown'
       END AS jobTitle
FROM employeesTable ET
LEFT JOIN ticketSellerTable TS ON ET.empID = TS.EID
LEFT JOIN usherTable UT ON ET.empID = UT.EID
ORDER BY ET.empFname;

SELECT * FROM employees_view;


-- This query calculates the total income from ticket sales by summing the prices of all tickets purchased.
SELECT SUM(price) AS total_income
FROM ticketTable;


-- This query calculates the average number of viewers per movie and the average income per movie, 
-- based on the number of viewers per screening as recorded in the screeningViewer table.
SELECT MT.mname, 
       ROUND(AVG(viewers_count), 3) AS avg_viewers, 
       ROUND(AVG(total_income), 3) AS avg_income
FROM movieTable MT
JOIN screeningTable ST ON MT.movieID = ST.MID
JOIN (
    -- calculate total number of viewers per screening
    SELECT SVT.SID, COUNT(SVT.VID) AS viewers_count
    FROM screeningViewerTable SVT
    GROUP BY SVT.SID
) VC ON ST.screenID = VC.SID
JOIN (
    -- calculate total income per screening
    SELECT TT.SID, SUM(TT.price) AS total_income
    FROM ticketTable TT
    GROUP BY TT.SID
) TI ON ST.screenID = TI.SID
GROUP BY MT.mname
HAVING AVG(viewers_count) >= 20;


-- This function checks if a movie is already scheduled 2 times on the same date
CREATE OR REPLACE FUNCTION check_movie_screenings()
RETURNS TRIGGER AS $$
DECLARE
    screenings_count INT;
BEGIN
    SELECT COUNT(*) INTO screenings_count
    FROM screeningTable
    WHERE MID = NEW.MID
    AND date = NEW.date;

    IF screenings_count = 2 THEN
        RAISE EXCEPTION 'The movie has already been scheduled 2 times on this date: %', NEW.date;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_screening_insert
BEFORE INSERT ON screeningTable
FOR EACH ROW
EXECUTE FUNCTION check_movie_screenings();


INSERT INTO screeningTable (screenID, date, time, MID, HID)
VALUES (6, '2024-09-27', '14:00:00', 40, 11); 

INSERT INTO screeningTable (screenID, date, time, MID, HID)
VALUES (7, '2024-09-27', '21:45:00', 40, 12);  -- Try to add new screening, but for this movie already have 2 screening in this spesific date


CREATE VIEW MovieScreening_view AS
SELECT 
    m.Mname AS Movie_Name,
    s.date AS Screening_Date,
    s.time AS Screening_Time,
    (ch.numOfChairs - COUNT(t.ticketID)) AS Available_Seats
FROM 
    screeningTable s
JOIN 
    movieTable m ON s.MID = m.movieID
JOIN 
    hallTable ch ON s.HID = ch.hallID
LEFT JOIN 
    ticketTable t ON s.screenID = t.SID
GROUP BY 
    m.Mname, s.date, s.time, ch.numOfChairs
ORDER BY 
    m.Mname, s.date, s.time;

SELECT * FROM MovieScreening_view;



 
