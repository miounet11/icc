import type { MetadataRoute } from "next";
import { marketingLocales } from "./marketing-copy";
import { siteConfig } from "./site-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const base = siteConfig.canonicalUrl;

  const entries: MetadataRoute.Sitemap = [];
  const pages = [
    { path: "", priority: 1 },
    { path: "/guide", priority: 0.85 },
    { path: "/changelog", priority: 0.8 },
  ];

  for (const page of pages) {
    const alternates: Record<string, string> = {};
    for (const locale of marketingLocales) {
      alternates[locale] = locale === "en" ? `${base}${page.path}` : `${base}/${locale}${page.path}`;
    }
    alternates["x-default"] = `${base}${page.path}`;

    entries.push({
      url: `${base}${page.path}`,
      lastModified: "2026-03-26",
      changeFrequency: "weekly",
      priority: page.priority,
      alternates: { languages: alternates },
    });
  }

  return entries;
}
