from pydantic import BaseModel, EmailStr
from typing import List, Optional, Any
from datetime import datetime
from .models import NumberStatus

class WhatsAppNumberBase(BaseModel):
    phone_number: str

class WhatsAppNumberCreate(WhatsAppNumberBase):
    pass

class WhatsAppNumber(WhatsAppNumberBase):
    id: int
    status: NumberStatus
    added_at: datetime
    needs_code_input: bool = False
    
    # --- ДОБАВЛЕНЫ ПОЛЯ ---
    work_started_at: Optional[datetime] = None
    current_earnings: float = 0.0
    
    class Config:
        from_attributes = True

class UserBase(BaseModel):
    email: EmailStr

class User(UserBase):
    id: int
    is_active: bool
    balance: float
    telegram_user_id: Optional[str] = None
    crypto_wallet_address: Optional[str] = None
    numbers: List[WhatsAppNumber] = []
    
    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user_role: str

class TelegramLoginRequest(BaseModel):
    init_data: str

class WalletUpdateRequest(BaseModel):
    address: str

class InfoUpdateRequest(BaseModel):
    data: dict[str, Any]