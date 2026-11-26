# MANIFEST — Headless Map UI overhaul

## Zadanie
Hub jest nieczytelny. Zamiast długiego menu bocznego: poziome menu wysokiego poziomu (części 0–6), które rozwija się w podpoziomy (dekompozycja).

## Decyzje Architektoniczne
- Główna nawigacja: poziomy pasek z 6 pozycjami (Start, Duży obraz, Klocki, Jak działa, Biznes, Referencje).
- Każda pozycja otwiera mega-menu z dekompozycją: Klocki = 7 kolumn (2.1–2.7), pozostałe = karty z krótkim opisem.
- Drugi wiersz: pasek podsekcji bieżącej części (rodzeństwo strony) + przełącznik ścieżki.
- Strona tematu: kolumna treści ~70 znaków, po prawej "Na tej stronie" (spis nagłówków H2) z podświetlaniem.
- Menu boczne usunięte. Telefon: hamburger z akordeonem części.
- Styl bez zmian: tokeny Enxoo z Agentic Enterprise Map.

## Stack Technologiczny
Statyczny HTML/CSS/JS generowany z markdown (tools/hub/build.py + template.html). Bez bibliotek.

## Known Risks
- Mega-menu na dotyku: otwieranie kliknięciem, nie najechaniem.
- Dostępność: aria-expanded, Escape zamyka, fokus klawiaturą.

## Open Questions
- Czy przełącznik ścieżki ma zostać widoczny stale (tak, w drugim wierszu).
