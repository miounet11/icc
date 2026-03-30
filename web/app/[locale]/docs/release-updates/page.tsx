import { useTranslations } from "next-intl";
import { getTranslations } from "next-intl/server";
import { CodeBlock } from "../../components/code-block";
import { Callout } from "../../components/callout";
import { siteConfig } from "../../../site-config";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "docs.releaseUpdates" });
  return {
    title: t("metaTitle"),
    description: t("metaDescription"),
  };
}

export default function ReleaseUpdatesPage() {
  const t = useTranslations("docs.releaseUpdates");

  return (
    <>
      <h1>{t("title")}</h1>
      <p>{t("intro")}</p>

      <h2>{t("userPathTitle")}</h2>
      <ol>
        <li>{t("userPath1")}</li>
        <li>{t("userPath2")}</li>
        <li>{t("userPath3")}</li>
        <li>{t("userPath4")}</li>
      </ol>

      <h2>{t("endpointsTitle")}</h2>
      <p>{t("endpointsDesc")}</p>
      <CodeBlock lang="text">{`${siteConfig.downloadUrl}
${siteConfig.appcastUrl}
${siteConfig.latestManifestUrl}
${siteConfig.remoteManifestUrl}`}</CodeBlock>

      <h2>{t("operatorPathTitle")}</h2>
      <ol>
        <li>{t("operatorPath1")}</li>
        <li>{t("operatorPath2")}</li>
        <li>{t("operatorPath3")}</li>
        <li>{t("operatorPath4")}</li>
        <li>{t("operatorPath5")}</li>
        <li>{t("operatorPath6")}</li>
      </ol>

      <h2>{t("artifactsTitle")}</h2>
      <CodeBlock lang="text">{`downloads/icc-macos.dmg
downloads/appcast.xml
downloads/latest.json
downloads/archive/v0.1.0/icc-macos.dmg
downloads/archive/v0.1.0/appcast.xml
downloads/remote/cmuxd-remote-manifest.json`}</CodeBlock>

      <h2>{t("controlTitle")}</h2>
      <p>{t("controlDesc")}</p>
      <CodeBlock lang="bash">{`scripts/release-config.sh
docs/release-update-rules.md
scripts/stage-website-release-assets.sh`}</CodeBlock>

      <h2>{t("manualCheckTitle")}</h2>
      <p>{t("manualCheckDesc")}</p>
      <CodeBlock lang="bash">{`curl -I ${siteConfig.downloadUrl}
curl ${siteConfig.appcastUrl}
curl ${siteConfig.latestManifestUrl}`}</CodeBlock>

      <Callout>{t("platformCallout")}</Callout>
    </>
  );
}
