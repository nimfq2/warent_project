import httpx
from .config import settings

API_URL = "https://pay.crypt.bot/api"

async def get_balance():
    headers = {"Crypto-Pay-API-Token": settings.CRYPTOBOT_API_TOKEN}
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(f"{API_URL}/getBalance", headers=headers)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"CryptoBot API request failed: {e}")
            return {"ok": False, "error": str(e)}