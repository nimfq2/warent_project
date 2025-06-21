from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import timedelta
from ... import crud, schemas, security, telegram_auth
from ...config import settings
from ..dependencies import get_db
from fastapi import APIRouter, Depends, HTTPException, Body
# ...

router = APIRouter()

class TokenGenerateRequest(BaseModel):
    telegram_user_id: str
    # TODO: Добавить секретный ключ от бота для защиты этого эндпоинта

@router.post("/generate-token", response_model=str)
def generate_token_for_bot(request: TokenGenerateRequest, db: Session = Depends(get_db)):
    """(Для бота) Генерирует одноразовый токен для входа."""
    # Создаем фейковые данные, так как у нас нет полного объекта user от Telegram
    tg_user_data = {"id": request.telegram_user_id}
    user = crud.get_or_create_user_by_telegram(db, tg_user_data)
    token = crud.generate_login_token(db, user)
    return token # Возвращаем просто строку с токеном

@router.post("/validate-token", response_model=schemas.TokenResponse)
def validate_token(token: str = Body(..., embed=True), db: Session = Depends(get_db)):
    """(Для фронтенда) Проверяет одноразовый токен и выдает JWT."""
    user = crud.get_user_by_login_token(db, token=token)
    if not user:
        raise HTTPException(status_code=400, detail="Invalid or expired token")
    
    admin_ids = [admin_id.strip() for admin_id in settings.ADMIN_TELEGRAM_IDS.split(',')]
    user_role = "admin" if user.telegram_user_id in admin_ids else "user"
    access_token = security.create_access_token(data={"sub": user.email})
    
    return {"access_token": access_token, "token_type": "bearer", "user_role": user_role}