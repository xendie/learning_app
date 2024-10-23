# Use an official Python runtime as a base image
FROM python:3.12.7-bookworm

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5000 (the default Flask port)
EXPOSE 5000

# Define environment variable to tell Flask to run the app in development mode
ENV FLASK_ENV=production

# Command to run the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]