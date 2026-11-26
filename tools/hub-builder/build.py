import os, re, json, sys, html
import markdown, yaml
REPO = sys.argv[1]; OUT = sys.argv[2]
files = {}
for root, _, fs in os.walk(REPO):
    if '.git' in root: continue
    for f in fs:
        if f.endswith('.md'):
            p = os.path.relpath(os.path.join(root, f), REPO)
            files[p] = open(os.path.join(root, f), encoding='utf-8').read()

def split(s):
    if s.startswith('---'):
        _, fm, body = s.split('---', 2)
        return yaml.safe_load(fm), body.strip()
    return {}, s

docs = {}
path2id = {}
titles = {}
for p, s in files.items():
    if p == 'README.md': continue
    fm, body = split(s)
    if not fm: continue
    docs[fm['id']] = dict(fm=fm, body=body, path=p)
    path2id[p] = fm['id']
    titles[fm['id']] = re.sub(r' — .*','', str(fm.get('title', fm['id'])))

def link_fix(html_s, cur_path):
    def rep(m):
        href = m.group(1)
        if href.startswith('http'):
            return f'href="{href}" target="_blank" rel="noopener"'
        target = os.path.normpath(os.path.join(os.path.dirname(cur_path), href.split('#')[0]))
        if target in path2id:
            return f'href="#{path2id[target]}" data-title="{path2id[target]}"'
        return f'href="#home"'
    return re.sub(r'href="([^"]+)"', rep, html_s)

def render(md_text, cur_path):
    md_text = re.sub(r'^# .*\n', '', md_text, count=1)  # title rendered separately
    h = markdown.markdown(md_text, extensions=['tables', 'fenced_code', 'sane_lists'])
    h = link_fix(h, cur_path)
    def nice(m):
        tid = m.group(2)
        t = titles.get(tid, tid)
        return f'<a href="#{tid}">{html.escape(t)}</a>'
    h = re.sub(r'<a href="#([^"]+)" data-title="([^"]+)"><code>[^<]*</code></a>', nice, h)
    h = h.replace(' data-title="', ' data-t="')
    h = h.replace('<strong>(Interpretation)</strong>', '<span class="tag-inf">Interpretation</span>')
    h = re.sub(r'\(Interpretation([^)]*)\)', r'<span class="tag-inf">Interpretation\1</span>', h)
    h = h.replace('<table>', '<div class="tbl"><table>').replace('</table>', '</table></div>')
    h = re.sub(r'<blockquote>', '<blockquote class="note">', h)
    return h

def summary(md_text):
    body = re.sub(r'^# .*\n', '', md_text, count=1)
    for para in re.split(r'\n\s*\n', body):
        p = para.strip()
        if not p or p.startswith(('#','|','>','-','*','```','1.')) or p.lower().startswith(('synthesis written','not one of','source:','entry-point','plain-language','checks against','every content')): continue
        t = re.sub(r'<[^>]+>',' ', markdown.markdown(p)); t = re.sub(r'\s+',' ', html.unescape(t)).strip()
        if len(t) > 40: return t[:220] + ('…' if len(t) > 220 else '')
    return ''

def plain(md_text):
    t = re.sub(r'<[^>]+>', ' ', markdown.markdown(md_text))
    return re.sub(r'\s+', ' ', html.unescape(t))[:6000]

# attach index pages to their topic
attach = {}
for i, d in docs.items():
    if d['fm'].get('type') == 'index' and d['fm'].get('docs_for'):
        attach[d['fm']['docs_for']] = i

inv = {v:k for k,v in attach.items()}
def remap(h):
    return re.sub(r'href="#([^"]+)"', lambda m: f'href="#{inv.get(m.group(1), m.group(1))}"', h)
OVR = {
 'glossary':'Plain-language definitions of every term used in the hub, with status and official source. Filterable.',
 'verification-log':'What was checked against official Salesforce documentation, when, and with what result.',
 'multi-framework-react-launch':'The April 2026 launch post for React on Salesforce. Historical: statuses are out of date.',
 'use-cases-telco':'What Salesforce ships for Communications Cloud today, versus patterns we propose. No client references.',
 'salesforce-in-claude-skills':'The 33 Salesforce in Claude skills for sellers, in 8 categories, with sample prompts. Beta.',
 'aiforce-claudeforce':'How AIforce, Claudeforce, Salesforce in Claude and Sales Cloud in Claude fit together, and what a client needs.',
 'request-journeys':'Three short stories that follow one request from start to finish: a manager in Claude, a developer, a telco order card.',
}
out = []
for i, d in docs.items():
    fm = d['fm']
    if fm.get('type') == 'index' and i in attach.values(): continue
    rec = dict(id=i, title=fm.get('title', i), type=fm.get('type'), part=str(fm.get('part', '')),
               tracks=fm.get('tracks', []), level=fm.get('level'), status=fm.get('status'),
               verified=str(fm.get('last_verified', '')), related=fm.get('related', []) or [],
               html=remap(render(d['body'], d['path'])), text=plain(d['body']), summary=OVR.get(i) or summary(d['body']),
               src='https://github.com/krystiandrozd-alt/headless-toolkit/blob/master/' + d['path'])
    if i in attach:
        ix = docs[attach[i]]
        rec['docs_html'] = remap(render(ix['body'], ix['path']))
        rec['docs_count'] = ix['body'].count('https://developer.salesforce.com') + ix['body'].count('https://help.salesforce.com')
    out.append(rec)

tpl = open(os.path.join(os.path.dirname(__file__), 'template.html'), encoding='utf-8').read()
data = json.dumps(out, ensure_ascii=False).replace('</', '<\\/')
open(OUT, 'w', encoding='utf-8').write(tpl.replace('/*__DATA__*/[]', data))
print(len(out), 'docs;', os.path.getsize(OUT)//1024, 'KB')
