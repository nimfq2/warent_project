import json
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Any

from ... import models
from ..dependencies import get_current_admin, get_current_user

router = APIRouter()
INFO_FILE_PATH = "app/info_data.json"

# Схема для валидации данных при обновлении
class InfoData(BaseModel):
    data: dict[str, Any]

@router.get("/", summary="Get public info")
def get_info(user: models.User = Depends(get_current_user)):
    """
    Возвращает публичную информацию (тарифы, новости) из JSON-файла.
    Доступно любому аутентифицированному пользователю.
    """
    try:
        with open(INFO_FILE_PATH, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Info file not found.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read info file: {e}")

@router.post("/", summary="Update public info (Admin only)")
def update_info(
    request: InfoData,
    admin: models.User = Depends(get_current_admin)
):
    """Обновляет информацию в JSON-файле. Доступно только админам."""
    try:
        with open(INFO_FILE_PATH, 'w', encoding='utf-8') as f:
            json.dump(request.data, f, ensure_ascii=False, indent=4)
        return {"status": "success", "data": request.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to write info file: {e}")