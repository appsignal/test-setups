FROM python:3.12-alpine
RUN pip install --no-cache-dir requests beautifulsoup4
COPY bot.py /bot.py
CMD ["python", "-u", "/bot.py"]
