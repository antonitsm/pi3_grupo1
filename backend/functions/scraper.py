import re
import subprocess
import requests
from google import genai
from google.genai import types

GEMINI_KEY = ""


url = "https://www.camaraita.sc.gov.br/ciga/popup/index.php?pagina=pasta_digital&documento_tipo=proposicao&documento=6003"

result = subprocess.run(
    ["./curl_chrome116", url],
    capture_output=True,
    text=True
)

print("Return code:", result.returncode)

URLS = re.findall(r'https?://[^\s"\'>]+', result.stdout)

URLS = list(dict.fromkeys(URLS))

DOC_EXTENSIONS = (
    ".pdf", ".doc", ".docx",
    ".xls", ".xlsx",
    ".ppt", ".pptx",
    ".odt", ".ods", ".odp",
    ".rtf", ".txt"
)

URLS = [
    url for url in URLS
    if url.lower().split("?")[0].endswith(DOC_EXTENSIONS)
]

print(URLS)

loaded_files = []

for file_url in URLS:
    try:
        response = requests.get(file_url, timeout=30)

        if response.status_code == 200:
            loaded_files.append({
                "url": file_url,
                "content": response.content,   # binary file data
                "content_type": response.headers.get("Content-Type")
            })

            print(f"Loaded: {file_url}")

        else:
            print(f"Failed ({response.status_code}): {file_url}")

    except Exception as e:
        print(f"Error loading {file_url}: {e}")

print(f"\nTotal loaded files: {len(loaded_files)}")


# --------------------


client = genai.Client(api_key=GEMINI_KEY)

all_summaries = []

for file_data in loaded_files:
    try:
        uploaded_file = types.Part.from_bytes(
            data=file_data["content"],
            mime_type=file_data["content_type"]
        )

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=[
                "Me de as seguintes informacoes em json: titulo, resumo, status (aprovado/reprovado/invalido), data e autores.",
                uploaded_file
            ]
        )

        summary = response.text

        all_summaries.append({
            "url": file_data["url"],
            "summary": summary
        })

        print(f"\n=== Summary for {file_data['url']} ===")
        print(summary)

    except Exception as e:
        print(f"Error summarizing {file_data['url']}: {e}")


# ----------------------------
# Final results
# ----------------------------

print("\nDone!")
print(f"Generated {len(all_summaries)} summaries.")