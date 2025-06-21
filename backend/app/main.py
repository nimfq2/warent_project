from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from .database import engine
from . import models, bot_sender, crud
from .config import settings
from .api.endpoints import auth, users, numbers, admin, info

models.Base.metadata.create_all(bind=engine)

# Создаем экземпляр нашего приложения
app = FastAPI(
    title="Warent API",
    description="API для сервиса аренды WhatsApp номеров.",
    version="1.0.0"
)

# Настраиваем CORS (Cross-Origin Resource Sharing)
# Это список адресов, с которых разрешено обращаться к нашему API.
origins = [
    "http://localhost:8080",      # Для локальной разработки Flutter
    "https://*.ngrok-free.app",   # Для туннелей ngrok
    "https://*.trycloudflare.com",# Для туннелей Cloudflare
    # В будущем сюда нужно будет добавить адрес вашего реального домена
    # "https://app.realise.fun",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],    # Разрешаем все методы (GET, POST, PATCH и т.д.)
    allow_headers=["*"],    # Разрешаем все заголовки
)

# Подключаем все наши "главы" API (роутеры) к основному приложению
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(numbers.router, prefix="/api/v1/numbers", tags=["Numbers"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(info.router, prefix="/api/v1/info", tags=["Information"])

# Создаем корневой эндпоинт для проверки, что API работает
@app.get("/")
def read_root():
    return {"status": "ok", "message": "Warent API is running."}
@app.post("/webhook/{token}")
async def process_telegram_update(token: str, request: Request):
    """
    Принимает обновления от Telegram.
    Токен в URL нужен для базовой защиты, чтобы никто другой не мог слать сюда запросы.
    """
    if token != settings.TELEGRAM_BOT_TOKEN:
        return {"ok": False, "error": "Invalid token"}

    data = await request.json()
    message = data.get("message")
    
    if message and message.get("text") == "/start":
        chat = message.get("chat")
        if chat:
            telegram_user_id = str(chat.get("id"))
            
            # Генерируем одноразовый токен для входа
            # Для этого нам нужна сессия БД, поэтому используем yield
            db_gen = get_db()
            db = next(db_gen)
            try:
                user = crud.get_or_create_user_by_telegram(db, {"id": telegram_user_id})
                login_token = crud.generate_login_token(db, user)
            finally:
                next(db_gen, None) # Закрываем сессию
            
            # Формируем URL для входа
            # ВАЖНО: Убедитесь, что ваш фронтенд опубликован по этому адресу
            login_url = f"https://app.realise.fun?token={login_token}" 
            
            # Отправляем приветственное сообщение
            await bot_sender.send_welcome_message(telegram_user_id, login_url)

    return {"ok": True}