# Scanner Health Checks
# A Medline branch checks its handheld scanners every 15 minutes. Print the first 10 check times.
# Expected: Check 1: 15 minutes after shift start … Check 10: 150 minutes after shift start
check_times = range(15, 151, 15)

for check, minutes in enumerate(check_times, start=1):
    print(f"Check {check}: {minutes} minutes after shift start")

why are they called katas
