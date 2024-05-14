from datetime import datetime, timedelta

print(datetime.now().date()+timedelta(days=5))
print(datetime.now().date())

print(datetime.now().date())
print(datetime.now().date()+timedelta(minutes=1) == datetime.now().date())
