import type { MetadataRoute } from "next";
import { marketingLocales } from "./marketing-copy";
import { siteConfig } from "./site-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const base = siteConfig.canonicalUrl;

  const entries: MetadataRoute.Sitemap = [];

  const alternates: Record<string, string> = {};
  for (const locale of marketingLocales) {
    alternates[locale] = locale === "en" ? base : `${base}/${locale}`;
  }
  alternates["x-default"] = base;

  entries.push({
    url: base,
    lastModified: "2026-03-25",
    changeFrequency: "weekly",
    priority: 1,
    alternates: { languages: alternates },
  });

  return entries;
}
