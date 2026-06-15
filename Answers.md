# Theory Questions — Answers (Viva Practice)

---

## Question 1: What role does a Foreign Key play in the Bookings table, and how does it safeguard against entering a ticket sale for a match that doesn't exist?

Think of a Foreign Key like a **cross-reference rule**. It says: "Before you save this value here, make sure it actually exists over there."

In our Bookings table, when a fan buys a ticket, we store a `match_id` to record which match they booked for. But what if someone accidentally types `match_id = 999`, and match 999 does not exist in the Matches table? Without any protection, the database would just save that booking — and now we have a ticket for a ghost match that nobody can find.

A Foreign Key prevents this. In our schema we wrote:

```sql
CONSTRAINT fk_match FOREIGN KEY (match_id) REFERENCES Matches(match_id)
```

This tells PostgreSQL: "Every time a new row is inserted into Bookings, go check the Matches table and confirm that `match_id` value actually exists there. If it does not — reject the insert."

So if someone tries to book `match_id = 999`:

```sql
INSERT INTO Bookings VALUES (506, 1, 999, 'D-01', 'Confirmed', 150);
```

PostgreSQL will throw an error and refuse to save it. The booking simply does not go through.

We have the same rule for `user_id` — you cannot create a booking for a user who does not exist in the Users table either.

In short, a Foreign Key acts like a **gatekeeper**. It makes sure every booking always points to a real match and a real user, keeping our data clean and trustworthy.

---

## Question 2: Why are we unable to use an aggregate function like COUNT(booking_id) inside a standard WHERE clause to filter match rows? How does HAVING solve this?

Here is a simple way to think about this. When PostgreSQL runs a query, it works in a specific order:

1. It reads the rows from the table (`FROM`)
2. It filters individual rows (`WHERE`)
3. It groups the remaining rows (`GROUP BY`)
4. It calculates group totals like `COUNT()` or `SUM()` (`SELECT`)

Notice that `WHERE` happens at **step 2** — before any grouping or counting. So when PostgreSQL is filtering with `WHERE`, it is looking at one row at a time. At that point, the count has not been calculated yet. There is nothing to compare against.

Imagine trying to count how many tickets are sold per match, and only show matches with more than 2 bookings:

```sql
-- This will FAIL
SELECT match_id, COUNT(booking_id)
FROM Bookings
WHERE COUNT(booking_id) > 2
GROUP BY match_id;
```

PostgreSQL will give an error because it cannot count while it is still in the filtering step.

`HAVING` solves this by adding a filter that runs **after** grouping and counting:

```sql
-- This works
SELECT match_id, COUNT(booking_id)
FROM Bookings
GROUP BY match_id
HAVING COUNT(booking_id) > 2;
```

Now the count is already calculated, and `HAVING` filters the groups based on that result.

**Simple rule to remember:**
- `WHERE` filters **individual rows** (before grouping)
- `HAVING` filters **groups** (after grouping and aggregating)

---

## Question 3: If a Primary Key column guarantees that all row entries are completely unique, why does the database system also explicitly forbid it from containing a NULL value?

Great question. The short answer is: **uniqueness alone is not enough to identify a row, because NULL does not mean "the same" or "different" — it means "unknown".**

In SQL, `NULL` is special. It does not equal anything, not even itself. So if you ask `NULL = NULL`, SQL does not say `TRUE` — it says `NULL` (unknown).

Now imagine if we allowed NULL as a Primary Key:

| booking_id | user_id |
|---|---|
| NULL | 1 |
| NULL | 2 |

Are these the same booking or two different bookings? The database literally cannot tell, because `NULL = NULL` has no answer. So the uniqueness check would never catch this as a duplicate — and now we have two rows that cannot be told apart.

A Primary Key has one job: **every row must have a unique, findable identity**. If a row's ID is `NULL`, it has no identity. You cannot search for it, you cannot reference it from the Bookings table as a Foreign Key, and you cannot reliably update or delete it.

Think of it like a student ID card. If a student's ID card is blank, you cannot look them up in the system, even if every other student has a unique number. The blank card breaks the whole system.

So the database enforces two rules together for Primary Keys:
- **UNIQUE** — no two rows can have the same value
- **NOT NULL** — every row must actually have a value

Both rules are needed. Without NOT NULL, uniqueness alone cannot do its job.

---

## Question 4: Imagine a newly registered fan who hasn't bought any match tickets yet. If you run a LEFT JOIN linking the Users table (left) to the Bookings table (right), what will the resulting rows look like for that specific fan?

In our sample data, **Jannat Ara** (user_id = 4) is a newly registered fan with no bookings at all. She does not appear in the Bookings table.

If we run our Query 5:

```sql
SELECT user_id, full_name, booking_id
FROM Users
LEFT JOIN Bookings USING (user_id);
```

The result looks like this:

| user_id | full_name | booking_id |
|---|---|---|
| 1 | Tanvir Rahman | 501 |
| 1 | Tanvir Rahman | 502 |
| 2 | Asif Haque | 503 |
| 2 | Asif Haque | 504 |
| 3 | Sajjad Rahman | 505 |
| 4 | Jannat Ara | NULL |

Jannat Ara appears in the result, but her `booking_id` shows as **NULL** — because there are no matching rows for her in the Bookings table.

This is exactly what `LEFT JOIN` is designed to do. It says: "Give me **all rows from the left table** (Users), and match them with the right table (Bookings) where possible. If there is no match, still include the left-side row — just fill the right-side columns with NULL."

If we had used an `INNER JOIN` instead, Jannat Ara would be **completely missing** from the results, because INNER JOIN only returns rows that have a match on both sides.

So LEFT JOIN is the right choice whenever you want to see all users — even the ones who have not done anything yet.

---

## Question 5: What is the difference between a main query and a subquery? In what scenarios would you choose to use a subquery over a standard JOIN operation?

A **main query** is the outer `SELECT` that gives you your final result. A **subquery** is a smaller `SELECT` written inside the main query, inside parentheses. The database runs the subquery first, gets a result, and then the main query uses that result.

Think of it like asking a friend two questions:
- First: "What is the most expensive ticket price?" → they say "150"
- Then: "Show me all matches cheaper than 150"

That is exactly how our Query 7 works:

```sql
SELECT match_id, fixture, base_ticket_price
FROM Matches
WHERE base_ticket_price < (
    SELECT MAX(base_ticket_price) FROM Matches
)
LIMIT 2;
```

The inner subquery calculates the max price (150). The outer query then uses that number to filter the results.

Similarly, Query 6 uses a subquery to find the average ticket cost first, then show only the bookings that cost more than that average:

```sql
SELECT booking_id, match_id, total_cost
FROM Bookings
WHERE total_cost > (
    SELECT AVG(total_cost) FROM Bookings
);
```

---

**When to use a subquery instead of a JOIN:**

| Use a subquery when... | Use a JOIN when... |
|---|---|
| You need one calculated value (like an average or max) to compare against | You need columns from both tables in your result |
| The result of the inner query is just a filter, not something you want to display | You want to combine information side-by-side from two tables |
| The logic reads naturally as "find rows where X is greater than [something calculated]" | You need to match many rows from one table to many rows in another |

The simplest way to remember it: **subqueries answer "compared to what?", JOINs answer "combined with what?"**
