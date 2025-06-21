from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ... import crud, schemas, models
from ..dependencies import get_current_user, get_db

router = APIRouter()

@router.get("/me", response_model=schemas.User)
def read_users_me(current_user: models.User = Depends(get_current_user)):
    """
    Возвращает профиль текущего аутентифицированного пользователя.
    Используется для получения актуальных данных, таких как баланс и ID.
    """
    return current_user

@router.post("/me/wallet", response_model=schemas.User)
def update_my_wallet(
    request: schemas.WalletUpdateRequest,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Обновляет адрес крипто-кошелька для текущего пользователя."""
    return crud.update_wallet_address(db, user=current_user, address=request.address)