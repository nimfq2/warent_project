import datetime
import enum
from sqlalchemy import (Boolean, Column, DateTime, Enum as SQLEnum, Float,
                        ForeignKey, Integer, String)
from sqlalchemy.orm import relationship
from .database import Base

class NumberStatus(enum.Enum):
    queued = "queued"
    active = "active"
    banned = "banned"
    pending_confirmation = "pending_confirmation"

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    balance = Column(Float, default=0.0)
    telegram_user_id = Column(String, unique=True, nullable=True, index=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    crypto_wallet_address = Column(String, nullable=True)
    referral_code = Column(String, unique=True, nullable=True)
    referred_by_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    numbers = relationship("WhatsAppNumber", back_populates="owner")
    login_token = Column(String, unique=True, nullable=True, index=True)
    login_token_expires_at = Column(DateTime, nullable=True)

class WhatsAppNumber(Base):
    __tablename__ = "whatsapp_numbers"
    id = Column(Integer, primary_key=True, index=True)
    phone_number = Column(String, unique=True, index=True, nullable=False)
    status = Column(SQLEnum(NumberStatus), default=NumberStatus.queued, nullable=False)
    added_at = Column(DateTime, default=datetime.datetime.utcnow)
    owner_id = Column(Integer, ForeignKey("users.id"))
    code_sent_at = Column(DateTime, nullable=True)
    
    # --- ДОБАВЛЕНО ПОЛЕ ---
    work_started_at = Column(DateTime, nullable=True)
    
    owner = relationship("User", back_populates="numbers", lazy="joined")