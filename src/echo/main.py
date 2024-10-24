import os
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from motor.motor_asyncio import AsyncIOMotorClient
from bson import ObjectId
import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta

# MongoDB 설정
MONGO_URL = os.getenv('MONGO_URL', 'mongodb+srv://ihyuns96:qwer1234@cluster0.xakad.mongodb.net/')
client = AsyncIOMotorClient(MONGO_URL)
db = client['mydatabase']
collection = db['users']

# FastAPI 앱 생성
app = FastAPI()

# CORS 미들웨어 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시에는 특정 도메인으로 제한하세요
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic 모델 정의
class User(BaseModel):
    email: EmailStr
    password: str

# 비밀번호 암호화 함수 (bcrypt 사용)
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

# JWT 설정
SECRET_KEY = "your-secret-key"  # 실제 프로덕션에서는 안전한 비밀키를 사용해야 합니다
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# 토큰 생성 함수
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# 비밀번호 확인 함수
def verify_password(plain_password, hashed_password):
    return bcrypt.checkpw(plain_password.encode(), hashed_password.encode())

@app.post("/signup")
async def create_user(user: User):
    try:
        # 기존 사용자 확인
        existing_user = await collection.find_one({"email": user.email})
        if existing_user:
            raise HTTPException(status_code=400, detail="이미 존재하는 이메일입니다")

        # 비밀번호 암호화 후 MongoDB에 저장
        hashed_password = hash_password(user.password)
        new_user = {
            "email": user.email,
            "password": hashed_password
        }
        result = await collection.insert_one(new_user)

        return {"id": str(result.inserted_id), "message": "사용자가 성공적으로 생성되었습니다"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

@app.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await collection.find_one({"email": form_data.username})
    if not user:
        raise HTTPException(status_code=400, detail="이메일 또는 비밀번호가 잘못되었습니다")
    if not verify_password(form_data.password, user["password"]):
        raise HTTPException(status_code=400, detail="이메일 또는 비밀번호가 잘못되었습니다")
    
    access_token = create_access_token(data={"sub": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}

# 새로운 Pydantic 모델 정의
class AnalysisResult(BaseModel):
    email: str
    result: dict

@app.post("/save_analysis_result")
async def save_analysis_result(analysis: AnalysisResult):
    try:
        # 분석 결과를 MongoDB에 저장
        result = await db['analysis_results'].insert_one({
            "email": analysis.email,
            "result": analysis.result
        })
        return {"message": "Analysis result saved successfully", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
