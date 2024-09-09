# Musewave

Musewave is an open-source music streaming platform powered by the Jamendo API. This project is developed as a university assignment for the Faculty of Information Technology in Mostar.

## Table of Contents

- [Introduction](#introduction)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Login Credentials](#login-credentials)
- [Future Plans and TODOs](#future-plans-and-todos)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Musewave is a music streaming platform that allows users to stream music from the Jamendo API. The project includes a user application for Android and web, and an admin desktop application. The backend, which consists of the API, listener, MSSQL database, RabbitMQ, and Redis, is fully dockerized.

## Technologies Used

- **Client**: Flutter/Dart
- **Backend**: .NET 8 with EF Core (Code First)
- **Database**: MSSQL
- **Containerization**: Docker
- **Message Broker**: RabbitMQ
- **Caching**: Redis

## Project Structure

- **Client**
  - Client App (Flutter for Android and Web)
  - Admin App (Flutter for Desktop)
- **Backend**
  - API
  - Listener
  - MSSQL
  - RabbitMQ
  - Redis

## Setup and Installation

### Prerequisites

Before running the project, ensure you have the following installed:

- [Android Studio](https://developer.android.com/studio)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

### Installation and Running the Project

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/mihigs/RS2_Musewave.git
    cd RS2_Musewave
    ```

2. **Build and Run Docker Containers**:
    ```bash
    docker-compose build
    docker-compose up
    ```

3. **Set Up Client Applications**:
    - Open the respective Flutter project (user app or admin app) in VSCode.
    - Select the appropriate device.
    - Use one of the premade launch configurations to run the app.

### Premade Launch Configurations

- **User App**:
  - Android (Docker)
  - Web (Docker)
  - Android
  - Web

- **Admin App**:
  - Windows (Docker)
  - Windows

## Login Credentials

Use the following credentials to log in:

- **Admin**
  - **Username**: admin@musewave.com
  - **Password**: Test_123

- **Artist**
  - **Username**: artist@musewave.com
  - **Password**: Test_123

- **User**
  - **Username**: user1@musewave.com
  - **Password**: Test_123

- **Dummy Credit Card**
  - **Card Number**: 4242 4242 4242 4242

## Future Plans and TODOs

- Develop a client desktop app and improve responsiveness
- Dockerize Flutter web builds
- Search by genre and genre playlists
- Implement "show more" functionality for Jamendo track search results
- Notification tray media controls
- Allow multiple artists to collaborate on tracks/albums
- Caching audio on the client side
- API token for the client app

## License

This project is open source and available under the [MIT License](LICENSE).

---

For any questions or issues, please contact the project maintainers.