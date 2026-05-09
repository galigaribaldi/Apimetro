import { SISTEMA_OPTIONS } from "../map/constants";

type Props = {
  id?: string;
  value: string;
  onChange: (value: string) => void;
};

export function SistemaFilter({ id = "sistema", value, onChange }: Props) {
  return (
    <div className="map-field">
      <label htmlFor={id}>Sistema de transporte</label>
      <select
        id={id}
        className="map-view__select"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      >
        {SISTEMA_OPTIONS.map((opt) => (
          <option key={opt.value || "todos"} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
    </div>
  );
}
