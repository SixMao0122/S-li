# S-li 安全性政策 (Security Policy)

`S-li` (Six Life Injoy / Shell Line Interface) 致力於提供安全、純粹且無後門的現代化終端提示符體驗。我們在設計之初便秉持 **Security-First (資安優先)** 原則。

---

## 核心資安原則

1. **零動態下載與無遠端程式碼執行 (No Arbitrary Remote Execution)**
   - `S-li` 全程採用原生透明腳本（PowerShell、Bash、Lua、CMD），不下載黑箱編譯之二進位可執行檔（`.exe` / `.dll`）。
   - 禁止在 Prompt 計算過程中使用動態 `Invoke-Expression`、`eval` 執行未受信任的外部字串。

2. **隱私防護與路徑遮蔽 (Privacy by Design)**
   - 支援 `Privacy Mode`：在進行螢幕錄影、線上會議分享或截圖時，可一鍵遮蔽 Windows 使用者名稱、電腦名稱或敏感路徑。
   - 預設將家目錄 `C:\Users\<username>` 自動正規化為 `~`，避免在公共場合展示個人真實姓名。

3. **敏感資訊與環境變數保護**
   - 核心邏輯僅偵測無害的狀態變數（如 `$env:VIRTUAL_ENV`、`$env:CONDA_DEFAULT_ENV`、Git 分支）。
   - 嚴格禁止讀取或印出潛在包含憑證的環境變數（如 `*_TOKEN`, `*_KEY`, `*_SECRET`, `PASSWORD` 等）。

4. **CI/CD 自動化安全掃描**
   - 每次 Push 與 Pull Request 皆由 GitHub Actions 運行 `Gitleaks` 掃描，防止任何 API 金鑰、認證金鑰誤推至版本庫。

---

## 回報安全性漏洞 (Reporting a Vulnerability)

如果您在 `S-li` 中發現任何潛在的安全性漏洞或隱私洩漏疑慮，請**切勿**直接建立公開 Issue。

請依照以下流程通報：
1. 請至本專案的 GitHub 頁面，點選 **Security** 分頁。
2. 點選 **Report a vulnerability** 提交私密回報。
3. 我們將於 48 小時內進行確認與評估，並在修補完成後統一發布安全性公告。

感謝您協助維護 `S-li` 的社群安全！
