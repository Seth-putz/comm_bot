








<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Comm Bot</title>

  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <style>
    /* Card entrance animation */
    .card-enter {
      opacity: 0;
      transform: translateY(8px);
      animation: enter 0.3s ease-out forwards;
    }

    @keyframes enter {
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* Recommended subtle emphasis */
    .recommended-card {
      box-shadow: 0 0 0 1px rgba(34,197,94,0.35);
    }

    /* NEW: stronger card presence */
    .response-card {
      padding: 1rem;
    }

    /* NEW: full-width (odd) card emphasis */
    .full-width-emphasis {
      background: linear-gradient(
        to right,
        rgba(59,130,246,0.06),
        rgba(59,130,246,0.02)
      );
      border-left: 4px solid rgba(59,130,246,0.45);
    }
  </style>
</head>

<body class="bg-slate-100 min-h-screen flex items-center justify-center">

<div class="w-full max-w-4xl p-6">
<div class="bg-white rounded-xl shadow-lg p-8 space-y-6">

  <!-- HEADER -->
  <header class="space-y-1">
    <h1 class="text-2xl font-semibold text-slate-800">
      Workplace Message Assistant
    </h1>
    <p class="text-slate-500 text-sm">
      Improve tone, clarity, and confidence before sending messages at work.
    </p>
  </header>

  <!-- MODE SWITCH -->
  <div class="space-y-1">
    <div class="flex space-x-2 bg-slate-100 p-1 rounded-lg w-fit">

      <button
        onclick="setMode('refine')"
        class="px-4 py-2 text-sm rounded-md bg-white shadow text-slate-800 font-medium"
      >
        Refine Message
      </button>

      <button
        onclick="setMode('reply')"
        class="px-4 py-2 text-sm rounded-md text-slate-600 hover:text-slate-800"
      >
        Response Helper
      </button>

    </div>

    <p id="mode_description" class="text-sm text-slate-500">
      Analyze and improve a message you’ve already written.
    </p>
  </div>

  <!-- INPUTS -->
  <div id="refine_input" class="space-y-2">
    <label class="block text-sm font-medium text-slate-700">
      Message you want to send
    </label>
    <textarea
      id="message"
      rows="4"
      class="w-full rounded-lg border border-slate-300 p-3"
    ></textarea>
  </div>

  <div id="reply_inputs" class="space-y-3 hidden">
    <textarea
      id="context_message"
      rows="3"
      class="w-full rounded-lg border p-3"
      placeholder="What the other person said"
    ></textarea>

    <textarea
      id="user_feelings"
      rows="3"
      class="w-full rounded-lg border p-3"
      placeholder="What you're feeling or trying to say"
    ></textarea>
  </div>

  <!-- ROLE + TONE -->
  <div class="grid grid-cols-2 gap-4">
    <select id="recipient_role" class="rounded-lg border p-2">
      <option>Boss / Manager</option>
      <option>Senior coworker</option>
      <option selected>Normal</option>
      <option>Coworker</option>
      <option>Client / External</option>
    </select>

    <select id="tone" class="rounded-lg border p-2">
      <option>Cautious</option>
      <option>Respectful</option>
      <option selected>Normal</option>
      <option>Confident</option>
      <option>Firm</option>
    </select>
  </div>

  <!-- RUN BUTTON -->
  <button
    id="run_button"
    onclick="analyze()"
    class="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-lg flex items-center justify-center gap-2 disabled:opacity-60"
  >
    <span id="run_text">Run Assistant</span>
    <svg
      id="spinner"
      class="hidden w-5 h-5 animate-spin"
      viewBox="0 0 24 24"
    >
      <circle
        cx="12"
        cy="12"
        r="10"
        class="opacity-25"
        stroke="white"
        stroke-width="4"
        fill="none"
      ></circle>
      <path
        d="M22 12a10 10 0 0 1-10 10"
        class="opacity-75"
        fill="white"
      ></path>
    </svg>
  </button>

  <!-- CONFIDENCE -->
  <div id="confidence_container" class="hidden space-y-1">
    <div class="text-sm text-slate-600">Perceived confidence</div>
    <div class="w-full h-2 bg-slate-200 rounded-full">
      <div id="confidence_fill" class="h-full bg-green-500 rounded-full"></div>
    </div>
    <div
      id="confidence_label"
      class="text-xs text-slate-600 font-medium"
    ></div>
  </div>

  <!-- RESPONSES -->
  <section class="space-y-2">
    <h2 class="text-sm font-medium text-slate-700">
      Suggested responses
    </h2>

    <div
      id="responses"
      class="grid grid-cols-1 md:grid-cols-2 gap-3"
    ></div>
  </section>

</div>
</div>

<script>
let currentMode = 'refine';

const modeState = {
  refine: { html: '', confidence: '' },
  reply: { html: '', confidence: '' }
};

function setMode(mode) {
  modeState[currentMode].html = responses.innerHTML;
  modeState[currentMode].confidence = confidence_container.innerHTML;
  confidence_container.classList.add('hidden');

  currentMode = mode;
  refine_input.classList.toggle('hidden', mode !== 'refine');
  reply_inputs.classList.toggle('hidden', mode !== 'reply');

  responses.innerHTML = modeState[mode].html || '';
  if (modeState[mode].confidence) {
    confidence_container.innerHTML = modeState[mode].confidence;
    confidence_container.classList.remove('hidden');
  }
}

function analyze() {
  const button = run_button;
  button.disabled = true;
  spinner.classList.remove('hidden');
  run_text.textContent = 'Running…';

  fetch(currentMode === 'refine' ? '/analyze' : '/assist', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: new URLSearchParams(
      currentMode === 'refine'
        ? {
            message: message.value,
            recipient_role: recipient_role.value,
            tone: tone.value
          }
        : {
            context_message: context_message.value,
            user_feelings: user_feelings.value,
            recipient_role: recipient_role.value,
            tone: tone.value
          }
    )
  })
  .then(r => r.json())
  .then(renderResponse)
  .finally(() => {
    button.disabled = false;
    spinner.classList.add('hidden');
    run_text.textContent = 'Run Assistant';
  });
}

function renderResponse(data) {
  responses.innerHTML = '';

  data.responses.forEach((r, i) => {
    const detected = [...r.text.matchAll(/\[(.*?)\]/g)].map(m => m[1]);
    const isRecommended = r.label === data.recommended;

    let rendered = r.text;
    detected.forEach(p => {
      rendered = rendered.replace(
        `[${p}]`,
        `<span class="bg-yellow-200 border border-yellow-500 text-yellow-900 px-1.5 py-0.5 rounded font-semibold">
          [${p}]
        </span>`
      );
    });

    const isLastOdd =
      data.responses.length % 2 === 1 &&
      i === data.responses.length - 1;

    const card = document.createElement('div');
    card.className = `
      border rounded-lg bg-slate-50 space-y-3 card-enter response-card
      ${isRecommended ? 'recommended-card' : ''}
      ${isLastOdd ? 'md:col-span-2 full-width-emphasis' : ''}
    `;

    card.innerHTML = `
      <div class="flex items-center justify-between gap-2">
        <div class="flex items-center gap-2">
          <div class="font-semibold text-sm text-slate-800">
            ${r.label}
          </div>
          ${isRecommended ? `
            <span class="text-xs px-2 py-0.5 rounded-full
              bg-green-100 text-green-700 border border-green-300">
              Recommended
            </span>
          ` : ''}
        </div>

        <button
          class="copy-btn text-xs px-3 py-1.5 rounded bg-slate-800 text-white shadow-sm"
          onclick="copyMessage(this, \`${r.text.replace(/`/g,'')}\`)">
          ${detected.length ? 'Copy cleaned' : 'Copy'}
        </button>
      </div>

      <div class="text-slate-800 text-[15px] leading-relaxed">
        ${rendered}
      </div>

      ${detected.length ? `
        <div class="space-y-1">
          ${detected.map(p => `
            <input
              data-placeholder="${p}"
              class="w-full border rounded p-2 text-xs"
              placeholder="Fill ${p}">
          `).join('')}
        </div>` : ''}

      <!-- EXPLANATION -->
      <div class="text-xs text-slate-600 bg-white rounded border p-2">
        <strong class="text-slate-700">Why this works:</strong>
        ${
          typeof r.explanation === 'string' && r.explanation.trim().length
            ? r.explanation
            : 'This version balances clarity and professionalism.'
        }
      </div>

      ${r.risk_note ? `
        <div class="text-xs text-amber-700 bg-amber-50 rounded border border-amber-200 p-2">
          <strong>Watch out:</strong>
          ${r.risk_note}
        </div>
      ` : ''}
    `;

    responses.appendChild(card);
  });

  confidence_container.classList.remove('hidden');
  confidence_fill.style.width = data.confidence_meter + '%';
  confidence_label.textContent =
    `${data.confidence_meter}% confidence · Recommended response highlighted`;
}

function copyMessage(button, text) {
  let final = text;
  const card = button.closest('.card-enter');

  card.querySelectorAll('input[data-placeholder]').forEach(input => {
    final = final.replace(
      `[${input.dataset.placeholder}]`,
      input.value || input.dataset.placeholder
    );
  });

  navigator.clipboard.writeText(final);

  const original = button.textContent;
  button.textContent = 'Copied ✓';
  button.classList.add('bg-green-600');

  setTimeout(() => {
    button.textContent = original;
    button.classList.remove('bg-green-600');
  }, 1000);
}
</script>

</body>
</html>


















































require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

ENV['api_key'] ||= File.read('.env').split('=').last.strip

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  erb :index
end

post '/analyze' do
  content_type :json
  analyze_message(
    params[:message],
    params[:recipient_role],
    params[:tone]
  )
end

post '/assist' do
  content_type :json
  assist_response(
    params[:context_message],
    params[:recipient_role],
    params[:user_feelings]
  )
end

# -----------------------

def analyze_message(text, role, tone)
  prompt = <<~PROMPT
    Rewrite the workplace message in three tones: Safe, Balanced, Direct.
    Keep intent identical. Do not invent context.

    Message:
    "#{text}"

    Output JSON only:
    {
      "responses":[
        {"label":"Safe","text":"..."},
        {"label":"Balanced","text":"..."},
        {"label":"Direct","text":"..."}
      ],
      "recommended":"Balanced",
      "confidence_meter": number between 60 and 95
    }
  PROMPT

  send_llm(prompt)
end

def assist_response(context_message, role, intent)
  prompt = <<~PROMPT
    Incoming message:
    "#{context_message}"

    User intent:
    "#{intent}"

    Recipient role:
    #{role}

    Return JSON only:
    {
      "responses":[
        {"label":"Safe","text":"..."},
        {"label":"Balanced","text":"..."},
        {"label":"Direct","text":"..."}
      ],
      "recommended":"Balanced",
      "confidence_meter": number between 65 and 95
    }
  PROMPT

  send_llm(prompt)
end

def send_llm(prompt)
  uri = URI("https://api.openai.com/v1/chat/completions")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  req = Net::HTTP::Post.new(uri, {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  })

  req.body = {
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: prompt }],
    temperature: 0.35
  }.to_json

  res = http.request(req)

  # 🔑 Parse model JSON before returning
  content = JSON.parse(res.body)["choices"][0]["message"]["content"]
  JSON.parse(content).to_json
end










































require 'sinatra'
require 'net/http'
require 'uri'
require 'json'

ENV['api_key'] ||= File.read('.env').split('=').last.strip

set :bind, '0.0.0.0'
set :port, 4567

get '/' do
  erb :index
end

post '/analyze' do
  content_type :json
  analyze_message(
    params[:message],
    params[:recipient_role],
    params[:tone]
  )
end

post '/assist' do
  content_type :json
  assist_response(
    params[:context_message],
    params[:recipient_role],
    params[:user_feelings]
  )
end

# -----------------------

def analyze_message(text, role, tone)
  prompt = <<~PROMPT
    Rewrite the workplace message in three tones: Safe, Balanced, Direct.
    Keep intent identical. Do not invent context.

    Message:
    "#{text}"

    Output JSON only:
    {
      "responses":[
        {"label":"Safe","text":"..."},
        {"label":"Balanced","text":"..."},
        {"label":"Direct","text":"..."}
      ],
      "recommended":"Balanced",
      "confidence_meter": number between 60 and 95
    }
  PROMPT

  send_llm(prompt)
end

def assist_response(context_message, role, intent)
  prompt = <<~PROMPT
    Incoming message:
    "#{context_message}"

    User intent:
    "#{intent}"

    Recipient role:
    #{role}

    Return JSON only:
    {
      "responses":[
        {"label":"Safe","text":"..."},
        {"label":"Balanced","text":"..."},
        {"label":"Direct","text":"..."}
      ],
      "recommended":"Balanced",
      "confidence_meter": number between 65 and 95
    }
  PROMPT

  send_llm(prompt)
end

def send_llm(prompt)
  uri = URI("https://api.openai.com/v1/chat/completions")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  req = Net::HTTP::Post.new(uri, {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  })

  req.body = {
    model: "gpt-4o-mini",
    messages: [{ role: "user", content: prompt }],
    temperature: 0.35
  }.to_json

  res = http.request(req)

  # 🔑 Parse model JSON before returning
  content = JSON.parse(res.body)["choices"][0]["message"]["content"]
  JSON.parse(content).to_json
end










##########################################################################
##########################################################################
##########################################################################











<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Comm Bot</title>

  <script src="https://cdn.tailwindcss.com"></script>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
</head>

<body class="bg-slate-100 min-h-screen flex items-center justify-center">

<div class="w-full max-w-4xl p-6">
<div class="bg-white rounded-xl shadow-lg p-8 space-y-8">

  <!-- HEADER -->
  <header class="space-y-2">
    <h1 class="text-2xl font-semibold text-slate-800">
      Workplace Message Assistant
    </h1>
    <p class="text-slate-500 text-sm">
      Improve tone, clarity, and confidence before sending messages at work.
    </p>
  </header>

  <!-- MODE SWITCH -->
  <div class="space-y-2">
    <div class="flex space-x-2 bg-slate-100 p-1 rounded-lg w-fit">

      <button
        onclick="setMode('refine')"
        class="px-4 py-2 text-sm rounded-md bg-white shadow text-slate-800 font-medium"
      >
        Refine Message
      </button>

      <button
        onclick="setMode('reply')"
        class="px-4 py-2 text-sm rounded-md text-slate-600 hover:text-slate-800"
      >
        Response Helper
      </button>

    </div>

    <p id="mode_description" class="text-sm text-slate-500">
      Analyze and improve a message you’ve already written.
    </p>
  </div>

  <!-- REFINE INPUT -->
  <div id="refine_input" class="space-y-2">
    <label class="block text-sm font-medium text-slate-700">
      Message you want to send
    </label>
    <textarea
      id="message"
      rows="4"
      class="w-full rounded-lg border border-slate-300 p-3"
    ></textarea>
  </div>

  <!-- RESPONSE HELPER INPUT -->
  <div id="reply_inputs" class="space-y-4 hidden">
    <textarea id="context_message" rows="3"
      class="w-full rounded-lg border p-3"
      placeholder="What the other person said"></textarea>

    <textarea id="user_feelings" rows="3"
      class="w-full rounded-lg border p-3"
      placeholder="What you're feeling or trying to say"></textarea>
  </div>

  <!-- ROLE + TONE -->
  <div class="grid grid-cols-2 gap-6">
    <select id="recipient_role" class="rounded-lg border p-2">
      <option>Boss / Manager</option>
      <option>Senior coworker</option>
      <option>Coworker</option>
      <option>Client / External</option>
    </select>

    <select id="tone" class="rounded-lg border p-2">
      <option>Very cautious</option>
      <option>Cautious</option>
      <option selected>Neutral professional</option>
      <option>Confident</option>
      <option>Firm</option>
    </select>
  </div>

  <!-- RUN BUTTON -->
  <button
    id="run_button"
    onclick="analyze()"
    class="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 rounded-lg flex items-center justify-center gap-2 disabled:opacity-60"
  >
    <span id="run_text">Run Assistant</span>

    <svg
      id="spinner"
      class="hidden w-5 h-5 animate-spin"
      viewBox="0 0 24 24"
    >
      <circle cx="12" cy="12" r="10"
        class="opacity-25"
        stroke="white"
        stroke-width="4"
        fill="none"></circle>
      <path
        d="M22 12a10 10 0 0 1-10 10"
        class="opacity-75"
        fill="white"></path>
    </svg>
  </button>

  <!-- CONFIDENCE -->
  <div id="confidence_container" class="hidden space-y-1">
    <div class="text-sm text-slate-600">Perceived confidence</div>
    <div class="w-full h-3 bg-slate-200 rounded-full">
      <div id="confidence_fill" class="h-full bg-green-500 rounded-full"></div>
    </div>
    <div id="confidence_label" class="text-xs text-slate-500"></div>
  </div>

  <!-- RESPONSES -->
  <div id="responses" class="space-y-6"></div>

</div>
</div>

<script>
let currentMode = 'refine';
let placeholderValues = {};

function setMode(mode) {
  currentMode = mode;
  refine_input.classList.toggle('hidden', mode !== 'refine');
  reply_inputs.classList.toggle('hidden', mode !== 'reply');
}

function analyze() {
  const button = document.getElementById('run_button');
  const spinner = document.getElementById('spinner');
  const text = document.getElementById('run_text');

  button.disabled = true;
  spinner.classList.remove('hidden');
  text.textContent = 'Running…';

  fetch(currentMode === 'refine' ? '/analyze' : '/assist', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: new URLSearchParams(
      currentMode === 'refine'
        ? { message: message.value, recipient_role: recipient_role.value, tone: tone.value }
        : { context_message: context_message.value, user_feelings: user_feelings.value, recipient_role: recipient_role.value }
    )
  })
  .then(r => {
    if (!r.ok) throw new Error('Network error');
    return r.json();
  })
  .then(renderResponse)
  .catch(err => {
    alert('Something went wrong. Check the console.');
    console.error(err);
  })
  .finally(() => {
    button.disabled = false;
    spinner.classList.add('hidden');
    text.textContent = 'Run Assistant';
  });
}

function renderResponse(data) {
  responses.innerHTML = '';
  placeholderValues = {};

  data.responses.forEach(r => {
    const detected = [...r.text.matchAll(/\[(.*?)\]/g)]
      .map(m => m[1])
      .filter(p =>
        !message.value.includes(`[${p}]`) &&
        !context_message.value.includes(`[${p}]`)
      );

    let rendered = r.text;
    detected.forEach(p => {
      placeholderValues[p] = '';
      rendered = rendered.replace(
        `[${p}]`,
        `<span class="inline-block bg-yellow-200 border border-yellow-400 text-yellow-900 font-semibold px-2 py-0.5 rounded">[${p}]</span>`
      );
    });

    const needsFill = detected.length > 0;

    const card = document.createElement('div');
    card.className = 'border rounded-lg p-4 bg-slate-50 space-y-3';
    card.innerHTML = `
      <div class="font-medium">${r.label}</div>
      <div class="text-slate-800">${rendered}</div>

      <div class="space-y-2 ${needsFill ? '' : 'hidden'}">
        ${detected.map(p => `
          <input
            class="w-full border rounded p-2 text-sm"
            placeholder="Fill ${p}"
            oninput="placeholderValues['${p}']=this.value">
        `).join('')}
      </div>

      <button
        class="text-sm px-3 py-1 rounded bg-slate-800 text-white"
        onclick="copyMessage(\`${r.text.replace(/`/g,'')}\`)">
        ${needsFill ? 'Copy cleaned message' : 'Copy message'}
      </button>
    `;
    responses.appendChild(card);
  });

  confidence_container.classList.remove('hidden');
  confidence_fill.style.width = data.confidence_meter + '%';
  confidence_label.textContent =
    `${data.confidence_meter}% confidence · Recommended: ${data.recommended}`;
}

function copyMessage(text) {
  let final = text;
  Object.entries(placeholderValues).forEach(([k, v]) => {
    final = final.replace(`[${k}]`, v || k);
  });
  navigator.clipboard.writeText(final);
}
</script>

</body>
</html>





























































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip

def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

  prompt = <<~PROMPT
    You are a professional workplace communication assistant.

    Analyze the following message written by a non-native English speaker.

    Your tasks:
    1. Detect any of the following issues if present:
       - "Sounds insecure" includes excessive hedging such as "try", "no promises", or disclaimers that may reduce perceived confidence in professional settings.
       - Clarity or grammar issues (e.g., spelling errors, incorrect tense, unnatural phrasing, or word order that may distract or confuse the reader)
       - Too informal
       - Passive-aggressive
       - Over-apologetic
       - Sounds commanding when it shouldn’t
    2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace.
    3. Rewrite the message into THREE variants according to:
       - Target role: #{role}
       - Desired mode: #{mode}
       - Keep the original meaning intact.
    4. Choose ONE variant as "recommended" based on the target role and desired mode.
    5. Briefly explain why the recommended variant is the safest or most appropriate choice for the given role and mode.

    CRITICAL CONSTRAINTS:
    - Do NOT add or strengthen commitments, deadlines, or guarantees.
    - Do NOT turn uncertainty into certainty.
    - Preserve the original level of commitment exactly.
    - If the original message avoids a promise, the rewrite must also avoid a promise.
    - It is acceptable to retain uncertainty if the original message expresses it.
    - Prefer professional phrasing of uncertainty rather than eliminating it.
    - "direct" should remove softeners like "try" where possible, while still avoiding guarantees.
    - Avoid repeating the same uncertainty phrasing across variants (e.g., "cannot guarantee").

    Variant definitions:
    - "safe": Very cautious, minimizes risk, preserves uncertainty clearly.
    - "balanced": Professional and confident while still respecting uncertainty.
    - "direct": Most assertive possible WITHOUT increasing commitment.
    - Each variant must be meaningfully distinct in tone, not just minor wording changes.

    Recommendation guidance:
    - Default to "balanced" unless the role or mode clearly favors caution or assertiveness.
    - The explanation should focus on perception, hierarchy, and professional risk — not grammar.
    - The explanation must be concise (one short sentence).

    IMPORTANT:
    - You MUST respond with valid JSON only.
    - Do NOT include markdown.
    - Do NOT include commentary outside the JSON.
    - If no issues are found, return an empty array for "issues".

    Output JSON schema:
    {
      "issues": [string],
      "explanation": string,
      "variants": {
        "safe": string,
        "balanced": string,
        "direct": string
      },
      "recommended": string,
      "recommendation_reason": string
    }

    Message to analyze:
    "#{text}"
  PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end

# -------------------------------
# NEW FUNCTION: RESPONSE ASSISTANCE
# -------------------------------

def assist_response(context_message, sender_role, user_feelings)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

  prompt = <<~PROMPT
    You are a professional workplace communication assistant helping a non-native English speaker respond to a message.

    The user may feel anxious, uncertain, or unclear about how to respond.
    Your job is to translate intent into safe, human, professional workplace language.

    Incoming message (context):
    "#{context_message}"

    Message is from:
    #{sender_role}

    The user describes their feelings or intent (may be unclear or informal):
    "#{user_feelings}"

    Your tasks:
    1. Infer the user's core intent as faithfully as possible without exaggeration.
    2. Generate THREE response variants that express this intent:
       - "safe": minimizes professional risk and de-escalates tension
       - "balanced": professional, clear, and appropriate for most workplaces
       - "direct": most honest and assertive expression WITHOUT being rude or increasing commitment
    3. Preserve uncertainty if the user's intent includes uncertainty.
    4. Do NOT add promises, deadlines, or guarantees unless the user explicitly states them.
    5. If the user's intended response could reasonably create professional risk, briefly flag the risk.
    6. If risk is flagged, offer up to TWO alternative phrasings that reduce risk while keeping similar intent.

    CRITICAL CONSTRAINTS:
    - Do NOT shame, judge, or moralize.
    - Do NOT force safer language; alternatives must be optional.
    - Keep responses natural and human, not corporate or robotic.
    - Avoid over-formality unless clearly required by hierarchy.

    IMPORTANT:
    - You MUST respond with valid JSON only.
    - Do NOT include markdown.
    - Do NOT include commentary outside the JSON.

    Output JSON schema:
    {
      "inferred_intent": string,
      "responses": {
        "safe": string,
        "balanced": string,
        "direct": string
      },
      "risk_flag": string | null,
      "safer_alternatives": [string]
    }
  PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You help users respond safely and naturally in workplace conversations." },
      { role: "user", content: prompt }
    ],
    temperature: 0.35
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end

# ---- OPTIONAL TEST FOR RESPONSE ASSISTANCE ----

response = assist_response(
  "Can you confirm this will be done by tomorrow?",
  "boss",
  "I feel pressured and unsure, I don't want to sound lazy but I really might not finish"
)

puts JSON.pretty_generate(response)
















































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip

def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

  prompt = <<~PROMPT
    You are a professional workplace communication assistant.

    Analyze the following message written by a non-native English speaker.

    Prefer natural, conversational professional English over formal or abstract wording.
    Avoid corporate jargon or overly stiff phrasing unless necessary.
    Use contractions (e.g., "I'm", "can't") where appropriate to sound human and natural.

    Your tasks:
    1. Detect any of the following issues if present:
       - "Sounds insecure" includes excessive hedging such as "try", "no promises", or disclaimers that may reduce perceived confidence in professional settings.
       - Clarity or grammar issues (e.g., spelling errors, incorrect tense, unnatural phrasing, or word order that may distract or confuse the reader)
       - Too informal
       - Passive-aggressive
       - Over-apologetic
       - Sounds commanding when it shouldn’t
    2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace, using plain and human language.
    3. Rewrite the message into THREE variants according to:
       - Target role: #{role}
       - Desired mode: #{mode}
       - Keep the original meaning intact.
    4. Choose ONE variant as "recommended" based on the target role and desired mode.
    5. Briefly explain why the recommended variant is the safest or most appropriate choice for the given role and mode.

    CRITICAL CONSTRAINTS:
    - Do NOT add or strengthen commitments, deadlines, or guarantees.
    - Do NOT turn uncertainty into certainty.
    - Preserve the original level of commitment exactly.
    - If the original message avoids a promise, the rewrite must also avoid a promise.
    - It is acceptable to retain uncertainty if the original message expresses it.
    - Prefer professional phrasing of uncertainty rather than eliminating it.
    - "direct" should remove softeners like "try" where possible, while still avoiding guarantees.
    - Avoid repeating the same uncertainty phrasing across variants (e.g., "cannot guarantee").

    Variant definitions:
    - "safe": Very cautious, minimizes risk, preserves uncertainty clearly.
    - "balanced": Professional and confident while still respecting uncertainty.
    - "direct": Most assertive possible WITHOUT increasing commitment.
    - Each variant must be meaningfully distinct in tone, not just minor wording changes.
    - Variants should sound like something a real person would naturally say at work, not like policy or legal language.

    Recommendation guidance:
    - Default to "balanced" unless the role or mode clearly favors caution or assertiveness.
    - The explanation should focus on perception, hierarchy, and professional risk — not grammar.
    - The explanation must be concise (one short sentence) and focus on how the message will likely be perceived by the recipient.

    IMPORTANT:
    - You MUST respond with valid JSON only.
    - Do NOT include markdown.
    - Do NOT include commentary outside the JSON.
    - If no issues are found, return an empty array for "issues".

    Output JSON schema:
    {
      "issues": [string],
      "explanation": string,
      "variants": {
        "safe": string,
        "balanced": string,
        "direct": string
      },
      "recommended": string,
      "recommendation_reason": string
    }

    Message to analyze:
    "#{text}"
  PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end

# ---- TEST ----

test_message = "I don't understand if it will be completed by satuday"

response = analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)

puts JSON.pretty_generate(response)









































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip

def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

  prompt = <<~PROMPT
    You are a professional workplace communication assistant.

    Analyze the following message written by a non-native English speaker.

    Your tasks:
    1. Detect any of the following issues if present:
       - "Sounds insecure" includes excessive hedging such as "try", "no promises", or disclaimers that may reduce perceived confidence in professional settings.
       - Too informal
       - Passive-aggressive
       - Over-apologetic
       - Sounds commanding when it shouldn’t
    2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace.
    3. Rewrite the message into THREE variants according to:
       - Target role: #{role}
       - Desired mode: #{mode}
       - Keep the original meaning intact.
    4. Choose ONE variant as "recommended" based on the target role and desired mode.

    CRITICAL CONSTRAINTS:
    - Do NOT add or strengthen commitments, deadlines, or guarantees.
    - Do NOT turn uncertainty into certainty.
    - Preserve the original level of commitment exactly.
    - If the original message avoids a promise, the rewrite must also avoid a promise.
    - It is acceptable to retain uncertainty if the original message expresses it.
    - Prefer professional phrasing of uncertainty rather than eliminating it.
    - "direct" should remove softeners like "try" where possible, while still avoiding guarantees.
    - Avoid repeating the same uncertainty phrasing across variants (e.g., "cannot guarantee").

    Variant definitions:
    - "safe": Very cautious, minimizes risk, preserves uncertainty clearly.
    - "balanced": Professional and confident while still respecting uncertainty.
    - "direct": Most assertive possible WITHOUT increasing commitment.
    - Each variant must be meaningfully distinct in tone, not just minor wording changes.

    Recommendation guidance:
    - Default to "balanced" unless the role or mode clearly favors caution or assertiveness.

    IMPORTANT:
    - You MUST respond with valid JSON only.
    - Do NOT include markdown.
    - Do NOT include commentary outside the JSON.
    - If no issues are found, return an empty array for "issues".

    Output JSON schema:
    {
      "issues": [string],
      "explanation": string,
      "variants": {
        "safe": string,
        "balanced": string,
        "direct": string
      },
      "recommended": string
    }

    Message to analyze:
    "#{text}"
  PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end

# ---- TEST ----

test_message = "I will try to finish this today but no promises."

response = analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)

puts JSON.pretty_generate(response)









































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip


def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

      prompt = <<~PROMPT
    You are a professional workplace communication assistant.

    Analyze the following message written by a non-native English speaker.

    Your tasks:
    1. Detect any of the following issues if present:
       - "Sounds insecure" includes excessive hedging such as "try", "no promises", or disclaimers that reduce confidence unnecessarily.
       - Too informal
       - Passive-aggressive
       - Over-apologetic
       - Sounds insecure
       - Sounds commanding when it shouldn’t
    2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace.
    3. Rewrite the message into THREE variants according to:
       - Target role: #{role}
       - Desired mode: #{mode}
       - Keep the original meaning intact.

     CRITICAL CONSTRAINTS:
    - Do NOT add or strengthen commitments, deadlines, or guarantees.
    - Do NOT turn uncertainty into certainty.
    - Preserve the original level of commitment exactly.
    - If the original message avoids a promise, the rewrite must also avoid a promise.
    - It is acceptable to retain uncertainty if the original message expresses it.
    - Prefer professional phrasing of uncertainty rather than eliminating it.
    - "direct" should remove softeners like "try" where possible, while still avoiding guarantees.

    Variant definitions:
    - "safe": Very cautious, minimizes risk, preserves uncertainty clearly.
    - "balanced": Professional and confident while still respecting uncertainty.
    - "direct": Most assertive possible WITHOUT increasing commitment.
    - Each variant must be meaningfully distinct in tone, not just minor wording changes.

    IMPORTANT:
    - You MUST respond with valid JSON only.
    - Do NOT include markdown.
    - Do NOT include commentary outside the JSON.
    - If no issues are found, return an empty array for "issues".

    Output JSON schema:
    {
      "issues": [string],
      "explanation": string,
      "variants": {
        "safe": string,
        "balanced": string,
        "direct": string
      }
    }

    Message to analyze:
    "#{text}"
  PROMPT



  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end




# ---- TEST ----

test_message = "I will try to finish this today but no promises."

response = analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)

puts JSON.pretty_generate(response)


































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip


def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

    prompt = <<~PROMPT
      You are a professional workplace communication assistant.

      Analyze the following message written by a non-native English speaker.

      Your tasks:
      1. Detect any of the following issues if present:
         - Too informal
         - Passive-aggressive
         - Over-apologetic
         - Sounds insecure
         - Sounds commanding when it shouldn’t
      2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace.
      3. Rewrite the message into THREE variants according to:
         - Target role: #{role}
         - Desired mode: #{mode}
         - Keep the original meaning intact.

      IMPORTANT:
      - You MUST respond with valid JSON only.
      - Do NOT include markdown.
      - Do NOT include commentary outside the JSON.
      - If no issues are found, return an empty array for "issues".
      CRITICAL CONSTRAINTS:
      - Do NOT add or strengthen commitments, deadlines, or guarantees.
      - Do NOT turn uncertainty into certainty.
      - Preserve the original level of commitment exactly.
      - If the original message avoids a promise, the rewrite must also avoid a promise.
      - It is acceptable to retain uncertainty if the original message expresses it.
      - Prefer professional phrasing of uncertainty rather than eliminating it.

      Output JSON schema:
      {
        "issues": [string],
        "explanation": string,
        "commitment_level": "non-committal | tentative | firm | guaranteed",
        "improved_message": string
      }

      Message to analyze:
      "#{text}"
    PROMPT



  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end




# ---- TEST ----

test_message = "I was thinking of maybe using the script for copying the scrape data as well as storing it in the original table."

response = analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)

puts JSON.pretty_generate(response)











































# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip


def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

    prompt = <<~PROMPT
      You are a professional workplace communication assistant.

      Analyze the following message written by a non-native English speaker.

      Your tasks:
      1. Detect any of the following issues if present:
         - Too informal
         - Passive-aggressive
         - Over-apologetic
         - Sounds insecure
         - Sounds commanding when it shouldn’t
      2. Briefly explain why each detected issue could be problematic in a professional English-speaking workplace.
      3. Rewrite the message according to:
         - Target role: #{role}
         - Desired mode: #{mode}
         - Keep the original meaning intact.

      IMPORTANT:
      - You MUST respond with valid JSON only.
      - Do NOT include markdown.
      - Do NOT include commentary outside the JSON.
      - If no issues are found, return an empty array for "issues".
      CRITICAL CONSTRAINTS:
      - Do NOT add or strengthen commitments, deadlines, or guarantees.
      - Do NOT turn uncertainty into certainty.
      - Preserve the original level of commitment exactly.
      - If the original message avoids a promise, the rewrite must also avoid a promise.

      Output JSON schema:
      {
        "issues": [string],
        "explanation": string,
        "improved_message": string
      }

      Message to analyze:
      "#{text}"
    PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  if result["error"]
    puts "API ERROR:"
    puts result["error"]["message"]
    exit
  end

  raw_content = result["choices"][0]["message"]["content"]

  begin
    JSON.parse(raw_content)
  rescue JSON::ParserError
    puts "MODEL RETURNED INVALID JSON:"
    puts raw_content
    exit
  end
end




# ---- TEST ----

test_message = "I will try to finish this today but no promises."

response = analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)

puts JSON.pretty_generate(response)





















# Creator: myself
# Date: 01-31-2026

require 'net/http'
require 'uri'
require 'json'

# Load API key from .env
ENV['api_key'] ||= File.read('.env').split('=').last.strip


def analyze_message(text, role, mode)
  uri = URI.parse("https://api.openai.com/v1/chat/completions")

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV['api_key']}"
  }

  prompt = <<~PROMPT
    You are a professional workplace communication assistant.

    Analyze the following message written by a non-native English speaker.

    Tasks:
    1. Detect potential issues:
       - Too informal
       - Passive-aggressive
       - Over-apologetic
       - Sounds insecure
       - Sounds commanding when it shouldn’t
    2. Briefly explain why each issue could be problematic in a professional English-speaking workplace.
    3. Rewrite the message according to:
       - Target role: #{role}
       - Desired mode: #{mode}
       - Keep the original meaning intact.

    Output format:
    Issues:
    - ...

    Explanation:
    ...

    Improved version:
    ...

    Message:
    "#{text}"
  PROMPT

  body = {
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: "You are a careful, professional business communication assistant." },
      { role: "user", content: prompt }
    ],
    temperature: 0.3
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, headers)
  request.body = body.to_json

  response = http.request(request)
  result = JSON.parse(response.body)

  result["choices"][0]["message"]["content"]
end




# ---- TEST ----

test_message = "I will try to finish this today but no promises."

puts analyze_message(
  test_message,
  "boss",
  "confident but not arrogant"
)