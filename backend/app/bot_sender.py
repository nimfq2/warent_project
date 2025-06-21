import httpx
import json
from .config import settings

BOT_API_URL = f"https://api.telegram.org/bot{settings.TELEGRAM_BOT_TOKEN}"

async def send_welcome_message(telegram_user_id: str, login_url: str):
    """
    Отправляет приветственное сообщение с картинкой и кнопкой для входа.
    """
    # Формируем кнопку "Login URL"
    login_button = {
        "type": "web_app",
        "text": "🚀 Войти в кабинет",
        "web_app": {"url": login_url}
    }
    keyboard = {"inline_keyboard": [[login_button]]}

    params = {
        'chat_id': telegram_user_id,
        'photo': settings.START_MESSAGE_IMAGE_URL,
        'caption': settings.START_MESSAGE_TEXT,
        'reply_markup': json.dumps(keyboard)
    }
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{BOT_API_URL}/sendPhoto", params=params)
            response.raise_for_status()
            return response.json().get("ok", False)
        except Exception as e:
            print(f"Failed to send welcome message: {e}")
            return False

async def send_photo_to_user(telegram_user_id: str, image_bytes: bytes, caption: str):
    """Отправляет сгенерированное/загруженное изображение пользователю."""
    files = {'photo': ('code.png', image_bytes, 'image/png')}
    params = {'chat_id': telegram_user_id, 'caption': caption}
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.post(f"{BOT_API_URL}/sendPhoto", params=params, files=files)
            response.raise_for_status()
            result = response.json()
            return result.get("ok", False)
        except Exception as e:
            print(f"Failed to send photo via Telegram: {e}")
            return False