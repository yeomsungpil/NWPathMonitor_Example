# 보일러 플레이트 이용 방법
<br>
<br>

## 1. 보일러 플레이트 template repository 체크 후 프로젝트 생성 

<img src="https://github.com/user-attachments/assets/d385811a-30b6-44c2-8ccf-046b20833df7" width="50%" alt="Image">
<br>

## 2. Clone
```bash
git clone <해당 레포지토리 git 주소> ("프로젝트명")
```
<br>

## 3. 터미널 사용하여 rename_script.sh 파일 생성
```bash
vi rename_script.sh
```
<br>

## 4. rename_script.sh에서 i 눌러서 작성가능하게 INSERT 활성화 후 Script 복사 -> 완료후 ESC , :wq 해서 파일 저장 
```bash
#!/bin/bash
OLD_PROJECT_NAME="boilerplate"  # 기존 프로젝트명 (현재 이름)
NEW_PROJECT_NAME="프로젝트명"        # 새로운 프로젝트명 (변경할 이름)

OLD_BUNDLE_ID="com.example.$OLD_PROJECT_NAME"
NEW_BUNDLE_ID="com.example.$NEW_PROJECT_NAME"

echo "🔄 프로젝트 이름을 $OLD_PROJECT_NAME -> $NEW_PROJECT_NAME 로 변경 중..."

1️⃣ **Xcode 프로젝트 파일 및 폴더명 변경 (boilerplate -> $NEW_PROJECT_NAME)**
echo "📂 Xcode 프로젝트 파일 및 폴더명 변경 중..."
find . -depth -name "*$OLD_PROJECT_NAME*" | while read FILE; do
  NEW_FILE=$(echo "$FILE" | sed "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g")
  mv "$FILE" "$NEW_FILE"
done

2️⃣ 소스코드 내에서 BoilerPlate -> $NEW_PROJECT_NAME 변경
echo "🔄 프로젝트 내부 문자열 변경 중..."
find . -type f -name "*" -exec sed -i '' "s/$OLD_PROJECT_NAME/$NEW_PROJECT_NAME/g" {} +

3️⃣ 번들 ID 변경
echo "🔄 번들 ID 변경 중..."
find . -type f -name "project.pbxproj" -exec sed -i '' "s/$OLD_BUNDLE_ID/$NEW_BUNDLE_ID/g" {} +

4️⃣ **Info.plist 경로 변경**
echo "🔄 Info.plist 경로 변경 중..."
find . -type f -name "project.pbxproj" -exec sed -i '' "s|$OLD_PROJECT_NAME/Info.plist|$NEW_PROJECT_NAME/Info.plist|g" {} +

6️⃣ Git 커밋 및 푸시
echo "🔄 변경 사항을 Git에 커밋하고 푸시하는 중..."
git add .
git commit -m "Refactored project from $OLD_PROJECT_NAME to $NEW_PROJECT_NAME"
git push origin main

echo "✅ 프로젝트 변경 완료! 🎉"
 ```

<br>

## 5. 터미널에 실행 권한 부여
* 터미널에서 실행 권한을 부여합니다
```bash
chmod +x rename_script.sh
```

<br>

## 6. 스크립트 실행
```bash
./rename_script.sh
