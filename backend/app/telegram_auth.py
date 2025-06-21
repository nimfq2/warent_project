import hmac
import hashlib
import json
from urllib.parse import unquote
from .config import settings

def is_valid_telegram_data(init_data: str) -> dict | None:
    try:
        parsed_data = {key: unquote(value) for key, value in (pair.split('=') for pair in init_data.split('&'))}
        received_hash = parsed_data.pop('hash')
        data_check_string = "\n".join(f"{key}={value}" for key, value in sorted(parsed_data.items()))
        secret_key = hmac.new("WebAppData".encode(), settings.TELEGRAM_BOT_TOKEN.encode(), hashlib.sha256).digest()
        calculated_hash = hmac.new(secret_key, data_check_string.encode(), hashlib.sha256).hexdigest()
        if calculated_hash == received_hash:
            return json.loads(parsed_data.get('user', '{}'))
        return None
    except Exception:
        return None