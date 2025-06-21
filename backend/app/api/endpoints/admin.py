from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from sqlalchemy.orm import Session
from typing import List

from ... import crud, schemas, models, cryptobot, bot_sender
from ..dependencies import get_db, get_current_admin

router = APIRouter()

@router.get("/dashboard-stats/", response_model=dict)
def get_dashboard_stats(
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Возвращает статистику для дашборда."""
    return crud.get_admin_dashboard_stats(db)

@router.get("/users/", response_model=List[schemas.User])
def read_all_users(
    skip: int = 0, limit: int = 100,
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Возвращает список всех пользователей."""
    return crud.get_all_users(db, skip=skip, limit=limit)

@router.get("/users/{user_id}", response_model=schemas.User)
def read_user_details(
    user_id: int,
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Возвращает детальную информацию о конкретном пользователе."""
    db_user = crud.get_user_by_id(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@router.patch("/users/{user_id}/status", response_model=schemas.User)
def update_user_active_status(
    user_id: int, is_active: bool,
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Изменяет статус активности пользователя."""
    admin_ids = settings.ADMIN_TELEGRAM_IDS.split(',')
    user_to_update = crud.get_user_by_id(db, user_id)
    if user_to_update and user_to_update.telegram_user_id in admin_ids:
        raise HTTPException(status_code=400, detail="Cannot change status of an admin.")
        
    updated_user = crud.update_user_status(db, user_id=user_id, is_active=is_active)
    if updated_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user

@router.get("/numbers/", response_model=List[schemas.WhatsAppNumber])
def read_all_numbers(
    skip: int = 0, limit: int = 100,
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Возвращает все номера в системе."""
    return crud.get_all_numbers(db, skip=skip, limit=limit)

@router.post("/numbers/{number_id}/send-image", response_model=schemas.WhatsAppNumber)
async def send_image_to_user(
    number_id: int,
    image_file: UploadFile = File(...),
    admin: models.User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    """(Админ) Принимает загруженное изображение, пересылает его пользователю."""
    db_number = db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.id == number_id).first()
    if not db_number or not db_number.owner or not db_number.owner.telegram_user_id:
        raise HTTPException(status_code=404, detail="Number or its owner not found.")

    image_bytes = await image_file.read()
    caption = f"Вам отправлен код для номера {db_number.phone_number}"

    success = await bot_sender.send_photo_to_user(
        telegram_user_id=db_number.owner.telegram_user_id,
        image_bytes=image_bytes,
        caption=caption
    )
    if not success:
        raise HTTPException(status_code=502, detail="Failed to send message via Telegram Bot.")

    updated_number = crud.set_number_status_to_pending(db, number_id=number_id)
    if updated_number is None:
        raise HTTPException(status_code=404, detail="Number not found after sending code.")
    return updated_number

@router.get("/cryptobot-balance/", response_model=dict)
async def get_cryptobot_balance(admin: models.User = Depends(get_current_admin)):
    """(Админ) Получает актуальный баланс из CryptoBot API."""
    return await cryptobot.get_balance()