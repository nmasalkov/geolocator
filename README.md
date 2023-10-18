# Geolocator API

This is a RESTful API for geolocation services. It allows you to perform various actions related to geolocating IP addresses and URLs.

## Getting Started

Follow these steps to set up and run the Geolocator API on your local machine:

1. Clone the repository:
   ```bash
   git clone git@github.com:nmasalkov/geolocator.git
   cd geolocator
   ```

    - **User Configuration**: Before proceeding, make sure to rename the `.env.example` file to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Build and start the Docker containers:
   ```bash
   docker-compose up -d --build
   ```

3. Wait for the application to start, and then run the following to create the database, run migrations, and seed the database:
   ```bash
   docker-compose run web rails db:create db:migrate db:seed
   ```

Now, the Geolocator API is up and running, and you can start using it.

## API Endpoints

The Geolocator API provides the following endpoints for various geolocation actions:

### 1. Get Locations - `GET /locations`

- Returns a list of locations with optional pagination.

### 2. Get Location Details - `GET /locations/:id`

- Returns details of a specific location by its ID.

### 3. Delete Location - `DELETE /locations/:id`

- Deletes a location by its ID.

### 4. Find Location - `GET /locations/find`

- Searches for a location by a search string (URL or IP address).

### 5. Create Location - `POST /locations`

- Creates a new location by providing a source (URL or IP address) and the type of source.

---

**Examples:**

#### Get Locations

- **Request:**
  ```
  GET /locations
  ```

- **Response:**
  ```
  {
    "locations": [array_of_location_objects],
    "pagination": {
      "total_pages": 2,
      "total_count": 20
    }
  }
  ```

#### Get Location Details

- **Request:**
  ```
  GET /locations/:id
  ```

- **Response:**
  ```
  {
    "id": 1,
    "ip_address": "192.168.1.1",
    "url": "http://example.com",
    "longitude": -120.5678,
    "latitude": 45.1234
  }
  ```

#### Delete Location

- **Request:**
  ```
  DELETE /locations/:id
  ```

- **Response:**
  ```
  {
    "message": "Location deleted successfully"
  }
  ```

#### Find Location

- **Request:**
  ```
  GET /locations/find?search_string=example.com
  ```

- **Response:**
  ```
  {
    "id": 1,
    "ip_address": "192.168.1.1",
    "url": "http://example.com",
    "longitude": -120.5678,
    "latitude": 45.1234
  }
  ```

#### Create Location

- **Request:**
  ```
  POST /locations
  {
    "source": "http://example.com",
    "type": "url"
  }
  ```

- **Response:**
  ```
  {
    "message": "Location created successfully",
    "id": 2,
    "ip_address": "192.168.1.2",
    "url": "http://example.com",
    "longitude": -120.5678,
    "latitude": 45.1234
  }
  ```

- **Request:**
  ```
  POST /locations
  {
    "source": "192.168.1.2",
    "type": "ip_address"
  }
  ```

- **Response:**
  ```
  {
    "message": "Location created successfully",
    "id": 2,
    "ip_address": "192.168.1.2",
    "url": "",
    "longitude": -120.5678,
    "latitude": 45.1234
  }
  ```

---
