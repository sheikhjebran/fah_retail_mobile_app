# FAH Retail Backend

FastAPI backend for FAH Retail Mobile App.

## Quick Setup

### 1. Create and activate virtual environment:
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python -m venv venv
source venv/bin/activate
```

### 2. Install dependencies:
```bash
pip install -r requirements.txt
```

### 3. Set up MySQL Database:

**Option A: Using MySQL directly**
```sql
mysql -u root -p
CREATE DATABASE fah_retail;
USE fah_retail;
SOURCE schema.sql;
```

**Option B: Using XAMPP**
1. Start XAMPP and enable MySQL
2. Open phpMyAdmin (http://localhost/phpmyadmin)
3. Create database named `fah_retail`
4. Import `schema.sql` file

### 4. Configure environment:
```bash
copy .env.example .env
```

Edit `.env` with your MySQL credentials:
```
DATABASE_URL=mysql+pymysql://root:yourpassword@localhost:3306/fah_retail
```

### 5. Start the server:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at http://localhost:8000

## API Documentation

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Test OTP Login

1. Send OTP: POST `/api/auth/send-otp`
   ```json
   {"phone": "9876543210"}
   ```

2. Check terminal for OTP (development mode prints it)

3. Verify OTP: POST `/api/auth/verify-otp`
   ```json
   {"phone": "9876543210", "otp": "123456"}
   ```

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app entry point
│   ├── config.py            # Configuration settings
│   ├── database.py          # Database connection
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── routes/              # API endpoints
│   └── utils/               # Utilities (JWT auth)
├── schema.sql               # MySQL database schema
├── requirements.txt         # Python dependencies
└── .env.example             # Environment variables template
```

## Troubleshooting

**Connection refused error:**
- Ensure MySQL is running
- Check DATABASE_URL in .env matches your MySQL credentials
- Backend server must be running on port 8000

**Import errors:**
- Make sure you're in the `backend` folder
- Activate the virtual environment
- Run `pip install -r requirements.txt`
