const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const port = 3000;

// إعداد لتخزين الأكواد في مجلد "codes"
const codesDir = path.join(__dirname, 'codes');

// التأكد من وجود المجلد لتخزين الأكواد
if (!fs.existsSync(codesDir)) {
    fs.mkdirSync(codesDir);
}

app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));

// دالة لتحويل النصوص إلى HTML entities (تشفير الأحرف الخاصة)
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// الصفحة الرئيسية التي تحتوي على نموذج إدخال الكود
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// صفحة عرض الكود عند الرابط الخاص به (عرض raw للكود فقط)
app.get('/view/:id', (req, res) => {
    const codeId = req.params.id;
    const filePath = path.join(codesDir, `${codeId}.txt`);

    if (fs.existsSync(filePath)) {
        const code = fs.readFileSync(filePath, 'utf-8');
        // تحويل الكود إلى HTML entities لعرضه كنص فقط
        const escapedCode = escapeHtml(code);
        res.send(`
            <pre style="white-space: pre-wrap; word-wrap: break-word;">${escapedCode}</pre>
        `);
    } else {
        res.status(404).send('الكود غير موجود!');
    }
});

// حفظ الكود في ملف
app.post('/save', (req, res) => {
    const code = req.body.code;
    const codeId = Date.now().toString();  // استخدام timestamp كـ ID فريد
    const filePath = path.join(codesDir, `${codeId}.txt`);

    // حفظ الكود في ملف
    fs.writeFileSync(filePath, code);

    // إرسال رابط الكود الجديد
    res.send(`
        <h2>تم حفظ الكود بنجاح!</h2>
        <p>رابط الكود الخاص بك: <a href="/view/${codeId}" target="_blank">اضغط هنا لعرض الكود</a></p>
    `);
});

// بدء الخادم
app.listen(port, () => {
    console.log(`خادم Express يعمل على http://localhost:${port}`);
});