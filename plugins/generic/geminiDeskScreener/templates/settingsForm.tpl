<div class="pkp_form" style="padding: 10px;">
<div style="margin-bottom: 15px;">
<p style="font-size: 13px; color: #475569; line-height: 1.5;">
Tentukan <strong>System Instruction, Validation Rules, dan JSON Schema Output</strong> yang akan digunakan oleh Gemini AI untuk desk screening.
</p>
</div>

<div class="section">
<label for="customPromptRuleText" style="font-weight: bold; font-size: 13px; display: block; margin-bottom: 6px; color: #1e293b;">
Custom System Prompt & Template Guidelines <span class="req" style="color: #dc2626;">*</span>
</label>
<textarea id="customPromptRuleText" rows="18" style="width: 100%; font-family: monospace; font-size: 12px; line-height: 1.4; padding: 12px; border: 1.5px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; background: #f8fafc; color: #0f172a;"></textarea>
</div>

<div style="margin-top: 20px; text-align: right;">
<button type="button" id="btnSavePromptRule" class="pkp_button" style="background: #2563eb; color: #ffffff; font-weight: bold; border: none; padding: 10px 22px; border-radius: 4px; cursor: pointer;">
💾 Simpan Pengaturan
</button>
</div>
</div>

<script type="text/javascript">
$(document).ready(function() {
var loadUrl = '{url router=$smarty.const.ROUTE_PAGE page="geminiDeskScreenerHandler" op="getPromptSettings"}';
var saveUrl = '{url router=$smarty.const.ROUTE_PAGE page="geminiDeskScreenerHandler" op="saveSettings"}';

// Muat nilai prompt saat form dibuka
$.getJSON(loadUrl, function(res) {
if (res && res.status) {
$('#customPromptRuleText').val(res.prompt);
}
});

// Aksi Simpan
$('#btnSavePromptRule').on('click', function(e) {
e.preventDefault();
var $btn = $(this);
var originalText = $btn.text();
$btn.prop('disabled', true).text('Menyimpan...');

var promptVal = $('#customPromptRuleText').val();

$.ajax({
url: saveUrl,
type: 'POST',
dataType: 'json',
data: { customPromptRule: promptVal },
success: function(resp) {
$btn.prop('disabled', false).text(originalText);
if (resp.status) {
alert('✅ Pengaturan Prompt Rule berhasil disimpan!');
} else {
alert('❌ Gagal: ' + resp.message);
}
},
error: function(xhr, status, err) {
$btn.prop('disabled', false).text(originalText);
alert('❌ Error AJAX: ' + err);
}
});
});
});
</script>
