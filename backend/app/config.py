from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int
    TELEGRAM_BOT_TOKEN: str
    CRYPTOBOT_API_TOKEN: str
    ADMIN_TELEGRAM_IDS: str = ""
    
    # --- НОВЫЕ ПОЛЯ ---
    START_MESSAGE_TEXT: str = "Welcome!"
    START_MESSAGE_IMAGE_URL: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

settings = Settings()