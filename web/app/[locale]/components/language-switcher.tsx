"use client";

import { usePathname, useRouter } from "next/navigation";
import { localeNames, type Locale } from "../../../i18n/routing";
import { marketingLocales } from "../../marketing-copy";

function localizePathname(pathname: string, nextLocale: Locale): string {
  const segments = pathname.split("/").filter(Boolean);
  const maybeLocale = segments[0];
  const hasLocale = marketingLocales.includes(maybeLocale as (typeof marketingLocales)[number]);
  const rest = hasLocale ? segments.slice(1) : segments;
  const nextSegments = nextLocale === "en" ? rest : [nextLocale, ...rest];

  return nextSegments.length === 0 ? "/" : `/${nextSegments.join("/")}`;
}

export function LanguageSwitcher({
  currentLocale = "en",
  label = "Language",
}: {
  currentLocale?: string;
  label?: string;
}) {
  const locale = marketingLocales.includes(currentLocale as (typeof marketingLocales)[number])
    ? (currentLocale as Locale)
    : "en";
  const router = useRouter();
  const pathname = usePathname();

  function onChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const newLocale = e.target.value as Locale;
    const nextPath = localizePathname(pathname, newLocale);
    const qs = typeof window !== "undefined" ? window.location.search : "";
    const hash = typeof window !== "undefined" ? window.location.hash : "";
    router.replace(`${nextPath}${qs}${hash}`);
  }

  return (
    <div className="flex items-center gap-2">
      <svg
        width="14"
        height="14"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="text-muted"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="10" />
        <path d="M2 12h20" />
        <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
      </svg>
      <select
        value={locale}
        onChange={onChange}
        className="text-xs text-muted bg-transparent border-none cursor-pointer hover:text-foreground transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-1"
        aria-label={label}
      >
        {marketingLocales.map((loc) => (
          <option key={loc} value={loc}>
            {localeNames[loc]}
          </option>
        ))}
      </select>
    </div>
  );
}
