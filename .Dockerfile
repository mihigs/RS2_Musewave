# Use the official image as a parent image
FROM mcr.microsoft.com/mssql/server:2019-latest

# Set the working directory in the container
WORKDIR /app

# Set environment variables
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=kikiriki

# Make SQL Server available to connections from outside the container
EXPOSE 1433

# Run the command on container startup
CMD ["/opt/mssql/bin/sqlservr"]
