import type { NumComercialOption } from "../map/useNumComercialOptions";

type Props = {
  id?: string;
  value: string;
  onChange: (value: string) => void;
  options: NumComercialOption[];
  loading?: boolean;
  error?: string | null;
};

export function NumComercialFilter({
  id = "num_comercial",
  value,
  onChange,
  options,
  loading = false,
  error = null,
}: Props) {
  const disabled = loading || Boolean(error);

  return (
    <div className="map-field">
      <label htmlFor={id}>Línea (número comercial)</label>
      <select
        id={id}
        className="map-view__select"
        value={value}
        disabled={disabled}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">
          {loading ? "Cargando líneas…" : "Todas las líneas"}
        </option>
        {options.map((opt) => (
          <option key={opt.value} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
      {error ? (
        <p className="map-sidebar__hint map-field__error" role="alert">
          No se pudieron cargar las líneas: {error}
        </p>
      ) : null}
    </div>
  );
}
