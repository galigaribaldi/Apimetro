import { MapView } from "./components/MapView";
import { ThemeToggle } from "./components/ThemeToggle";
import "./App.css";

function App() {
  return (
    <div className="app-root">
      <header className="app-header">
        <div className="app-header__inner">
          <div className="app-header__logo">
            <img
              src="/apimetro-mark.svg"
              width={38}
              height={38}
              alt=""
              className="app-header__logo-img"
            />
            <div>
              <div className="app-header__title">Apimetro</div>
              <div className="app-header__subtitle">API de Movilidad CDMX</div>
            </div>
          </div>
          <div className="app-header__right">
            <nav className="app-header__nav" aria-label="Enlaces">
              <a className="app-nav-link" href="/docs">
                Referencia API
              </a>
              <a className="app-nav-link" href="/swagger/index.html">
                Swagger UI
              </a>
              <a
                className="app-nav-link"
                href="https://github.com/galigaribaldi/Apimetro"
                target="_blank"
                rel="noopener noreferrer"
              >
                GitHub
              </a>
            </nav>
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main className="app-main">
        <MapView />
      </main>
    </div>
  );
}

export default App;
