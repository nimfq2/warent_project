import json
from datetime import datetime
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ... import crud, schemas, models
from ..dependencies import get_current_user, get_db

router = APIRouter()
INFO_FILE_PATH = "app/info_data.json"

@router.get("/", response_model=List[schemas.WhatsAppNumber])
def read_user_numbers(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Возвращает список номеров ТЕКУЩЕГО пользователя с расчетом заработка."""
    try:
        with open(INFO_FILE_PATH, 'r', encoding='utf-8') as f:
            pricing_info = json.load(f)
        rate_per_hour = pricing_info.get('base_rate_per_hour', 0.0)
    except Exception:
        rate_per_hour = 0.0

    numbers_db = crud.get_numbers_by_user(db=db, user_id=current_user.id)
    
    numbers_schema = []
    for num in numbers_db:
        num_schema = schemas.WhatsAppNumber.from_orm(num)
        
        if num.status == models.NumberStatus.active and num.work_started_at:
            hours_worked = (datetime.utcnow() - num.work_started_at).total_seconds() / 3600
            num_schema.current_earnings = hours_worked * rate_per_hour
        
        if num.status == models.NumberStatus.pending_confirmation:
            num_schema.needs_code_input = True
        
        numbers_schema.append(num_schema)
            
    return numbers_schema

@router.post("/", response_model=schemas.WhatsAppNumber)
def create_number_for_user(
    number: schemas.WhatsAppNumberCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Добавляет новый номер для ТЕКУЩЕГО пользователя."""
    # TODO: Добавить проверку на дубликат номера в базе
    return crud.create_user_number(db=db, number=number, user_id=current_user.id)

@router.post("/{number_id}/confirm-connection", response_model=schemas.WhatsAppNumber)
def confirm_connection(
    number_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """(Пользователь) Подтверждает, что он ввел код и подключил номер."""
    updated_number = crud.confirm_number_connection(db, number_id=number_id, user_id=current_user.id)
    if updated_number is None:
        raise HTTPException(status_code=404, detail="Number not found or you don't have permission.")
    return updated_number