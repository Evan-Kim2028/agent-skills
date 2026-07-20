# Mobile app ECharts verification

Prove under **mobile-app-echarts-visual** at **~390×844** and **≥1280**.

## Evidence preferred

1. Unit tests on option builders (axisLabel fontSize, grid mins).  
2. Playwright e2e **gate:** `frontend/e2e/tests/32-card-echarts-mobile-geometry.spec.ts`
   (canvas box inside chart root, width ≥ ~300 @ 390, no body overflow).  
3. Screenshot at 390 of primary card price chart.

## Sources

- [Bremer mobile vs desktop](https://www.visualcinnamon.com/2019/04/mobile-vs-desktop-dataviz/)  
- [Tableau mobile dashboards](https://www.tableau.com/blog/mobile-dashboard-design-less-more-small-screen-47854)  
