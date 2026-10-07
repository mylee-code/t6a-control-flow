# Warehouse Audit Calendar
# For days 1–30, apply these rules:

# Every 3rd day → Cycle count
# Every 5th day → Scanner audit
# Days that are both → FULL AUDIT
# Any other day → Normal operations

# Expected: Day 3: Cycle count, Day 5: Scanner audit, Day 15: FULL AUDIT, Day 30: FULL AUDIT
for day in range(1, 31):

    if day % 4 == 0 and day % 6 == 0:
        print(f"Day {day}: FULL AUDIT")
    elif day % 4 == 0:
        print(f"Day {day}: Cycle count")
    elif day % 6 == 0:
        print(f"Day {day}: Scanner audit")
    else:
        print(f"Day {day}: Normal operations")
shoutout larry
