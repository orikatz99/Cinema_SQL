## Cinema Management System🎬
This is my final project for the SQL course, completed on behalf of Afka College.  
I chose to develop a cinema management system.  
During the project, I defined the system's structure, its entities, and the relationships between them.  
I then built the system using SQL.  
Additionally, I implemented functions, triggers, and queries to manage the system in the most efficient way.

**Project report :**  [Project description.pdf](https://github.com/orikatz99/Cinema_SQL/blob/main/Project_description.pdf)  
**Project presentation :**  [Cinema presentation.pptx](https://github.com/orikatz99/Cinema_SQL/blob/main/Cinema_presentation.pptx)

## ERD Diagram
<img src="https://github.com/user-attachments/assets/57041d30-0189-4bda-b46a-4363c6d8c8d2" alt="WelcomePage" width="50%" height="50%">

## System Entities:
### 1. **Cinema**
- Holds the cinema details, including a unique number and an address.
- The system is designed for a single cinema.

### 2. **Employees**
- The employees are divided into ushers and tickets sellers.
- Each employee has attributes such as name, gender, date of birth, and salary.
- ushers have a unique attribute of the number of customers they have assisted.
- tickets sellers have an attribute representing the number of tickets they have sold.

### 3. **Movies and Screenings**
- Each movie has attributes such as ID, name, genre, rating, and duration.
- Each screening is associated with a specific movie and hall, with attributes including date and time.
-  Screenings are managed dynamically, and available seats are calculated based on the number of tickets sold.
  
### 4. **Viewers and Tickets**
- Viewers can attend multiple screenings, and each screening can have several viewers.
- Each ticket has an ID, price, and category (Regular: 40₪, Discount: 80₪, VIP: 100₪).


## Key Functionalities
1. **Seat Availability Check**  
   - A function named "check_availability" ensures that before purchasing a ticket, seat availability is verified for the selected screening.

2. **Triggers**  
   - A trigger checks seat availability using the "check_availability" function before each ticket purchase.
   - A trigger is set up before any screening insert that activates the function "check_movie_screenings" to ensure that a specific movie does not have more than 2 screenings in one day.

3. **Data Management**  
   - Includes SQL queries for inserting new tickets, updating screening schedules, and deleting outdated or low-rated movies.

4. **Employee Bonus System**  
   - A query awards a salary bonus to outstanding employees (based on performance criteria like ticket sales and customer assistance).

5. **Views for Data Display**  
   - "employees_view": Displays employees' first names, last names, and roles, sorted alphabetically, excluding salary information, so that this information is not accessible to everyone..
   - "usherForHall_view" : Display the list of halls along with the name of the usher assigned to each hall.
   - "usherScreening_view": Shows ushers and their assigned screening shifts.
   - "CinemaOverview": Displays movie screenings, organized by title, date, time, and available seats.

6. **Revenue and Viewer Analytics**  
   - Queries to calculate total revenue from ticket sales and average viewers per movie.
   - query that calculates the average number of viewers and revenue for each movie, and displays the most popular and profitable movies
