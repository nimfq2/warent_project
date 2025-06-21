from sqlalchemy.orm import Session
from datetime import datetime
import random
import string
from . import models, schemas, security
# ...
import uuid
from datetime import timedelta

def generate_login_token(db: Session, user: models.User) -> str:
    """Генерирует и сохраняет одноразовый токен для входа."""
    token = str(uuid.uuid4())
    user.login_token = token
    user.login_token_expires_at = datetime.utcnow() + timedelta(minutes=1)
    db.commit()
    db.refresh(user)
    return token

def get_user_by_login_token(db: Session, token: str) -> models.User | None:
    """Находит пользователя по одноразовому токену и проверяет срок его жизни."""
    user = db.query(models.User).filter(models.User.login_token == token).first()
    if user and user.login_token_expires_at > datetime.utcnow():
        # Сразу же "сжигаем" токен после использования
        user.login_token = None
        user.login_token_expires_at = None
        db.commit()
        return user
    return None

# --- Пользователи ---
def get_user_by_id(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_or_create_user_by_telegram(db: Session, tg_user_data: dict) -> models.User:
    telegram_id = str(tg_user_data['id'])
    user = db.query(models.User).filter(models.User.telegram_user_id == telegram_id).first()
    if user:
        return user
    
    new_email = f"tg_user_{telegram_id}@warent.app"
    if db.query(models.User).filter(models.User.email == new_email).first():
        new_email = f"tg_user_{telegram_id}_{int(datetime.utcnow().timestamp())}@warent.app"
    
    hashed_password = security.get_password_hash(''.join(random.choices(string.ascii_letters + string.digits, k=16)))
    referral_code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))

    db_user = models.User(email=new_email, hashed_password=hashed_password, telegram_user_id=telegram_id, referral_code=referral_code)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
    
def get_all_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def update_user_status(db: Session, user_id: int, is_active: bool):
    db_user = get_user_by_id(db, user_id)
    if db_user:
        db_user.is_active = is_active
        db.commit()
        db.refresh(db_user)
    return db_user

def update_wallet_address(db: Session, user: models.User, address: str):
    user.crypto_wallet_address = address
    db.commit()
    db.refresh(user)
    return user

# --- Номера ---
def get_numbers_by_user(db: Session, user_id: int):
    return db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.owner_id == user_id).all()

def get_all_numbers(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.WhatsAppNumber).offset(skip).limit(limit).all()

def create_user_number(db: Session, number: schemas.WhatsAppNumberCreate, user_id: int):
    db_number = models.WhatsAppNumber(**number.dict(), owner_id=user_id)
    db.add(db_number)
    db.commit()
    db.refresh(db_number)
    return db_number

def set_number_status_to_pending(db: Session, number_id: int):
    db_number = db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.id == number_id).first()
    if db_number:
        db_number.status = models.NumberStatus.pending_confirmation
        db_number.code_sent_at = datetime.utcnow()
        db.commit()
        db.refresh(db_number)
    return db_number

def confirm_number_connection(db: Session, number_id: int, user_id: int):
    """Пользователь подтверждает подключение. Меняем статус и ставим таймер."""
    db_number = db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.id == number_id, models.WhatsAppNumber.owner_id == user_id).first()
    if db_number and db_number.status == models.NumberStatus.pending_confirmation:
        db_number.status = models.NumberStatus.active
        db_number.code_sent_at = None
        # --- УСТАНАВЛИВАЕМ ВРЕМЯ НАЧАЛА РАБОТЫ ---
        db_number.work_started_at = datetime.utcnow()
        db.commit()
        db.refresh(db_number)
    return db_number

# --- Статистика ---
def get_admin_dashboard_stats(db: Session) -> dict:
    return {
        'total_users': db.query(models.User).count(),
        'active_numbers': db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.status == models.NumberStatus.active).count(),
        'queued_numbers': db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.status == models.NumberStatus.queued).count(),
        'banned_numbers': db.query(models.WhatsAppNumber).filter(models.WhatsAppNumber.status == models.NumberStatus.banned).count(),
    }