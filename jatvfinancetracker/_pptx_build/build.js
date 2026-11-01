// Build the JATV Finance Tracker — Final Project Report deck.
const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const sharp = require("sharp");
const fa = require("react-icons/fa");
const md = require("react-icons/md");

// ── Palette (matches the app's brand) ────────────────────────────────────────
const BRAND = "4A90D9";        // primary blue
const BRAND_DARK = "1A56C4";   // deeper blue
const NAVY = "1A1A2E";         // primary text
const SLATE = "475569";        // body text
const MUTED = "94A3B8";        // captions
const BG = "F8FAFC";           // pale background
const CARD = "FFFFFF";         // cards
const BORDER = "E2E8F0";       // hairline
const ACCENT_GREEN = "16A34A"; // success
const ACCENT_RED = "DC2626";   // alert
const ACCENT_PURPLE = "7B2FBE";// goals/family

// ── Helpers ──────────────────────────────────────────────────────────────────
async function iconPng(IconComponent, color = "#" + BRAND, size = 256) {
  const svg = ReactDOMServer.renderToStaticMarkup(
    React.createElement(IconComponent, { color, size: String(size) })
  );
  const buf = await sharp(Buffer.from(svg)).png().toBuffer();
  return "image/png;base64," + buf.toString("base64");
}

function makeShadow() {
  return {
    type: "outer",
    color: "0F172A",
    blur: 12,
    offset: 3,
    angle: 90,
    opacity: 0.08,
  };
}

(async () => {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE"; // 13.3 x 7.5
  pres.author = "The Vinh Vuong & James Luciano";
  pres.title = "JATV Finance Tracker — Final Project Report";

  const SLIDE_W = 13.3;
  const SLIDE_H = 7.5;

  // Pre-render icons we'll use repeatedly
  const icCheck = await iconPng(fa.FaCheckCircle, "#" + BRAND);
  const icCode = await iconPng(fa.FaCode, "#" + BRAND);
  const icDb = await iconPng(fa.FaDatabase, "#" + BRAND);
  const icLock = await iconPng(fa.FaLock, "#" + BRAND);
  const icWallet = await iconPng(fa.FaWallet, "#" + BRAND);
  const icChart = await iconPng(fa.FaChartLine, "#" + BRAND);
  const icBullseye = await iconPng(fa.FaBullseye, "#" + BRAND);
  const icUsers = await iconPng(fa.FaUsers, "#" + BRAND);
  const icGlobe = await iconPng(fa.FaGlobe, "#" + BRAND);
  const icMoon = await iconPng(fa.FaMoon, "#" + BRAND);
  const icFire = await iconPng(fa.FaFire, "#" + BRAND);
  const icBook = await iconPng(fa.FaBookOpen, "#" + BRAND);
  const icMobile = await iconPng(fa.FaMobileAlt, "#" + BRAND);
  const icUser = await iconPng(fa.FaUser, "#FFFFFF");
  const icSpace = await iconPng(md.MdSpaceDashboard, "#" + BRAND);
  const icPaint = await iconPng(fa.FaPaintBrush, "#" + BRAND);
  const icBox = await iconPng(fa.FaCubes, "#" + BRAND);

  // Reusable: brand title strip at top of content slides
  function addContentTitle(slide, title, kicker) {
    slide.addShape(pres.shapes.OVAL, {
      x: 0.7, y: 0.55, w: 0.18, h: 0.18,
      fill: { color: BRAND }, line: { type: "none" },
    });
    if (kicker) {
      slide.addText(kicker.toUpperCase(), {
        x: 0.96, y: 0.5, w: 8, h: 0.3,
        fontSize: 11, fontFace: "Calibri", color: BRAND, bold: true,
        charSpacing: 4, margin: 0,
      });
    }
    slide.addText(title, {
      x: 0.7, y: kicker ? 0.85 : 0.65, w: 12, h: 0.7,
      fontSize: 30, fontFace: "Georgia", color: NAVY, bold: true,
      margin: 0,
    });
  }

  function addFooter(slide, slideNumber) {
    slide.addText("JATV Finance Tracker  ·  Final Project Report", {
      x: 0.7, y: SLIDE_H - 0.45, w: 8, h: 0.3,
      fontSize: 10, fontFace: "Calibri", color: MUTED, margin: 0,
    });
    slide.addText(String(slideNumber), {
      x: SLIDE_W - 1.0, y: SLIDE_H - 0.45, w: 0.3, h: 0.3,
      fontSize: 10, fontFace: "Calibri", color: MUTED, align: "right", margin: 0,
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 1 — Title
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: "0B1437" };

    slide.addShape(pres.shapes.OVAL, {
      x: SLIDE_W - 3.2, y: -1.0, w: 5.5, h: 5.5,
      fill: { color: BRAND, transparency: 80 }, line: { type: "none" },
    });
    slide.addShape(pres.shapes.OVAL, {
      x: SLIDE_W - 2.4, y: 3.5, w: 4.0, h: 4.0,
      fill: { color: BRAND_DARK, transparency: 85 }, line: { type: "none" },
    });

    slide.addText("JATV Finance Tracker", {
      x: 0.9, y: 0.8, w: 8, h: 0.4,
      fontSize: 14, fontFace: "Calibri", color: BRAND, bold: true,
      charSpacing: 5, margin: 0,
    });

    slide.addText("Final Project Report", {
      x: 0.9, y: 2.0, w: 11, h: 1.4,
      fontSize: 60, fontFace: "Georgia", color: "FFFFFF", bold: true,
      margin: 0,
    });

    slide.addText("A Flutter & Firebase personal finance application", {
      x: 0.9, y: 3.4, w: 11, h: 0.6,
      fontSize: 20, fontFace: "Calibri", color: "CBD5E1", italic: true,
      margin: 0,
    });

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.9, y: 4.3, w: 0.9, h: 0.04,
      fill: { color: BRAND }, line: { type: "none" },
    });

    slide.addText("Presented by", {
      x: 0.9, y: 4.5, w: 4, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: MUTED,
      charSpacing: 3, margin: 0,
    });
    slide.addText([
      { text: "The Vinh Vuong", options: { bold: true, color: "FFFFFF", breakLine: true } },
      { text: "James Luciano", options: { bold: true, color: "FFFFFF" } },
    ], {
      x: 0.9, y: 4.85, w: 6, h: 1.0,
      fontSize: 20, fontFace: "Calibri", margin: 0,
    });

    slide.addText("Submission · Sunday, May 17, 2026", {
      x: 0.9, y: SLIDE_H - 0.7, w: 8, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: MUTED,
      charSpacing: 3, margin: 0,
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 2 — Project Overview
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Project Overview", "01 · Introduction");

    slide.addText(
      "JATV Finance Tracker is a cross-platform mobile application that helps users " +
      "manage their personal finances. The app combines transaction logging, " +
      "budgeting, goal-based savings, and household sharing into a single, " +
      "themable interface built on Flutter and powered by Firebase.",
      {
        x: 0.7, y: 1.85, w: 6.4, h: 2.4,
        fontSize: 15, fontFace: "Calibri", color: SLATE,
        paraSpaceAfter: 8, valign: "top", margin: 0,
      }
    );

    const cards = [
      { ic: icWallet, title: "Track", text: "Income, expenses & transfers" },
      { ic: icBullseye, title: "Save", text: "Goal contributions & withdrawals" },
      { ic: icChart, title: "Analyze", text: "Money-flow charts by category" },
      { ic: icUsers, title: "Share", text: "Family plans with shared budgets" },
    ];
    const cardW = 2.8, cardH = 1.4, gap = 0.2;
    cards.forEach((c, i) => {
      const col = i % 2, row = Math.floor(i / 2);
      const x = 7.4 + col * (cardW + gap);
      const y = 1.85 + row * (cardH + gap);
      slide.addShape(pres.shapes.RECTANGLE, {
        x, y, w: cardW, h: cardH,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
        shadow: makeShadow(),
      });
      slide.addImage({ data: c.ic, x: x + 0.2, y: y + 0.22, w: 0.38, h: 0.38 });
      slide.addText(c.title, {
        x: x + 0.7, y: y + 0.2, w: cardW - 0.85, h: 0.42,
        fontSize: 15, fontFace: "Calibri", color: NAVY, bold: true, margin: 0,
      });
      slide.addText(c.text, {
        x: x + 0.2, y: y + 0.72, w: cardW - 0.35, h: 0.5,
        fontSize: 11, fontFace: "Calibri", color: SLATE, margin: 0,
      });
    });

    const stats = [
      { num: "7", label: "Languages supported" },
      { num: "6", label: "Main feature modules" },
      { num: "3", label: "Firebase services" },
      { num: "2", label: "Theme modes" },
    ];
    stats.forEach((s, i) => {
      const x = 0.7 + i * 3.05;
      slide.addText(s.num, {
        x, y: 5.6, w: 1.0, h: 0.8,
        fontSize: 44, fontFace: "Georgia", color: BRAND, bold: true, margin: 0,
      });
      slide.addText(s.label, {
        x: x + 1.05, y: 5.85, w: 1.9, h: 0.5,
        fontSize: 11, fontFace: "Calibri", color: SLATE, margin: 0,
      });
    });

    addFooter(slide, 2);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 3 — Team
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Team", "02 · The Developers");

    function memberCard(x, name, role, ownership) {
      const w = 5.6, h = 4.5;
      slide.addShape(pres.shapes.RECTANGLE, {
        x, y: 1.9, w, h,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
        shadow: makeShadow(),
      });
      slide.addShape(pres.shapes.OVAL, {
        x: x + 0.45, y: 2.2, w: 1.1, h: 1.1,
        fill: { color: BRAND }, line: { type: "none" },
      });
      slide.addImage({ data: icUser, x: x + 0.73, y: 2.48, w: 0.54, h: 0.54 });

      slide.addText(name, {
        x: x + 1.8, y: 2.25, w: w - 2.0, h: 0.5,
        fontSize: 22, fontFace: "Georgia", color: NAVY, bold: true, margin: 0,
      });
      slide.addText(role, {
        x: x + 1.8, y: 2.75, w: w - 2.0, h: 0.35,
        fontSize: 12, fontFace: "Calibri", color: BRAND, bold: true,
        charSpacing: 2, margin: 0,
      });

      slide.addShape(pres.shapes.LINE, {
        x: x + 0.45, y: 3.55, w: w - 0.9, h: 0,
        line: { color: BORDER, width: 0.75 },
      });

      slide.addText("OWNERSHIP", {
        x: x + 0.45, y: 3.7, w: 3, h: 0.3,
        fontSize: 10, fontFace: "Calibri", color: MUTED, bold: true,
        charSpacing: 3, margin: 0,
      });
      slide.addText(ownership, {
        x: x + 0.45, y: 4.0, w: w - 0.9, h: 2.2,
        fontSize: 12, fontFace: "Calibri", color: SLATE,
        paraSpaceAfter: 6, margin: 0,
      });
    }

    memberCard(
      0.7,
      "The Vinh Vuong",
      "Full-Stack Developer",
      [
        { text: "Authentication & account flows", options: { bullet: true, breakLine: true } },
        { text: "Transaction History & Goals modules", options: { bullet: true, breakLine: true } },
        { text: "Profile, Settings & dark mode", options: { bullet: true, breakLine: true } },
        { text: "Localization (5 languages added)", options: { bullet: true, breakLine: true } },
        { text: "Shared theming & navigation utilities", options: { bullet: true } },
      ]
    );
    memberCard(
      7.0,
      "James Luciano",
      "Full-Stack Developer",
      [
        { text: "[ Add ownership area here ]", options: { bullet: true, breakLine: true, italic: true, color: MUTED } },
        { text: "[ Add module / feature ]", options: { bullet: true, breakLine: true, italic: true, color: MUTED } },
        { text: "[ Add module / feature ]", options: { bullet: true, breakLine: true, italic: true, color: MUTED } },
        { text: "Base localization (English & French)", options: { bullet: true, breakLine: true } },
        { text: "[ Add module / feature ]", options: { bullet: true, italic: true, color: MUTED } },
      ]
    );

    addFooter(slide, 3);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 4 — Tech Stack
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Technology Stack", "03 · Foundations");

    const techs = [
      { ic: icMobile, label: "Flutter 3.x", sub: "Cross-platform UI framework" },
      { ic: icCode, label: "Dart 3.x", sub: "Application logic & state" },
      { ic: icFire, label: "Firebase Auth", sub: "Email/password authentication" },
      { ic: icDb, label: "Cloud Firestore", sub: "Real-time NoSQL database" },
      { ic: icSpace, label: "MVVM Pattern", sub: "Model / View / ViewModel architecture" },
      { ic: icPaint, label: "Material 2", sub: "Theming + Light & Dark modes" },
    ];

    const colW = 6.0, rowH = 1.0, gapY = 0.15;
    techs.forEach((t, i) => {
      const col = i % 2, row = Math.floor(i / 2);
      const x = 0.7 + col * (colW + 0.3);
      const y = 2.0 + row * (rowH + gapY);

      slide.addShape(pres.shapes.RECTANGLE, {
        x, y, w: colW, h: rowH,
        fill: { color: BG }, line: { color: BORDER, width: 0.5 },
      });
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x + 0.18, y: y + 0.18, w: 0.65, h: 0.65,
        fill: { color: CARD }, line: { color: BORDER, width: 0.5 },
      });
      slide.addImage({ data: t.ic, x: x + 0.3, y: y + 0.3, w: 0.42, h: 0.42 });

      slide.addText(t.label, {
        x: x + 1.0, y: y + 0.18, w: colW - 1.1, h: 0.4,
        fontSize: 16, fontFace: "Calibri", color: NAVY, bold: true, margin: 0,
      });
      slide.addText(t.sub, {
        x: x + 1.0, y: y + 0.55, w: colW - 1.1, h: 0.35,
        fontSize: 11, fontFace: "Calibri", color: SLATE, margin: 0,
      });
    });

    addFooter(slide, 4);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 5 — Prototype
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Prototype & UI Mockups", "04 · Design");

    slide.addText(
      "Initial mockups guided the visual direction. Below are placeholder slots " +
      "for the Figma exports and early screen mockups — add each image directly " +
      "into the matching frame.",
      {
        x: 0.7, y: 1.85, w: 12, h: 0.6,
        fontSize: 13, fontFace: "Calibri", color: SLATE, italic: true, margin: 0,
      }
    );

    const frameW = 3.85, frameH = 4.0, gap = 0.25;
    const startX = (SLIDE_W - (frameW * 3 + gap * 2)) / 2;
    const labels = ["Login / Signup", "Home Dashboard", "Goal Tracker"];

    labels.forEach((lbl, i) => {
      const x = startX + i * (frameW + gap);
      slide.addShape(pres.shapes.RECTANGLE, {
        x, y: 2.65, w: frameW, h: frameH,
        fill: { color: BG }, line: { color: BORDER, width: 0.75 },
      });
      slide.addShape(pres.shapes.RECTANGLE, {
        x: x + 0.2, y: 2.85, w: frameW - 0.4, h: frameH - 0.85,
        fill: { color: "FFFFFF" },
        line: { color: MUTED, width: 1, dashType: "dash" },
      });
      slide.addText("Add screenshot here", {
        x: x + 0.2, y: 2.85 + (frameH - 0.85) / 2 - 0.2,
        w: frameW - 0.4, h: 0.4,
        fontSize: 11, fontFace: "Calibri", color: MUTED, align: "center", italic: true, margin: 0,
      });
      slide.addText(lbl, {
        x, y: 2.65 + frameH - 0.5, w: frameW, h: 0.4,
        fontSize: 12, fontFace: "Calibri", color: NAVY, bold: true,
        align: "center", margin: 0,
      });
    });

    addFooter(slide, 5);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 6 — Functional Requirements
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Functional Requirements", "05 · What the system does");

    const reqs = [
      { title: "User account management", desc: "Register, sign in, verify email, reset password, and edit profile." },
      { title: "Transaction logging", desc: "Add, view, edit, and delete income, expense, and transfer transactions." },
      { title: "Budget tracking", desc: "Create monthly/weekly/yearly budgets per category with progress alerts." },
      { title: "Financial goals", desc: "Create goals; contributions and withdrawals auto-log as transactions." },
      { title: "Family sharing", desc: "Create family groups, invite members, and log shared expenses." },
      { title: "Visual analytics", desc: "Cash-flow charts, category breakdowns, and savings overview." },
      { title: "User preferences", desc: "Toggle dark mode and switch between 7 supported languages." },
      { title: "Search, filter & sort", desc: "Filter transactions by type, date range, and sort by amount or date." },
    ];

    const rowH = 0.6, gapY = 0.05;
    reqs.forEach((r, i) => {
      const y = 1.85 + i * (rowH + gapY);
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 12, h: rowH,
        fill: { color: i % 2 === 0 ? BG : CARD }, line: { type: "none" },
      });
      // Thin brand-blue left strip as visual accent (no ID text)
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 0.1, h: rowH,
        fill: { color: BRAND }, line: { type: "none" },
      });
      slide.addText(r.title, {
        x: 0.95, y, w: 4.0, h: rowH,
        fontSize: 13, fontFace: "Calibri", color: NAVY, bold: true,
        valign: "middle", margin: 0,
      });
      slide.addText(r.desc, {
        x: 5.05, y, w: 7.55, h: rowH,
        fontSize: 11.5, fontFace: "Calibri", color: SLATE,
        valign: "middle", margin: 0,
      });
    });

    addFooter(slide, 6);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 7 — Non-Functional Requirements
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Non-Functional Requirements", "06 · How the system performs");

    const items = [
      { ic: icLock, title: "Security", text: "Firebase Auth, email verification, password reset, hashed credentials, and Firestore security rules per user." },
      { ic: icChart, title: "Performance", text: "Sub-second screen loads with cached reads. Transactions stream from Firestore on demand to keep memory low." },
      { ic: icBox, title: "Reliability", text: "Auto-retry on transient errors. Optimistic UI for goal contributions; rollback on failure." },
      { ic: icGlobe, title: "Localization", text: "7 languages: English, Spanish, French, German, Chinese, Japanese, Vietnamese. Centralized string registry." },
      { ic: icMoon, title: "Accessibility", text: "High-contrast dark mode, scalable typography, semantic labels, and platform-default screen-reader support." },
      { ic: icSpace, title: "Maintainability", text: "MVVM separation, shared theme controller, route observer, and unified bottom-nav widget across screens." },
    ];

    const cardW = 6.0, cardH = 1.55, gapY = 0.15;
    items.forEach((it, i) => {
      const col = i % 2, row = Math.floor(i / 2);
      const x = 0.7 + col * (cardW + 0.3);
      const y = 2.0 + row * (cardH + gapY);
      slide.addShape(pres.shapes.RECTANGLE, {
        x, y, w: cardW, h: cardH,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
        shadow: makeShadow(),
      });
      slide.addShape(pres.shapes.OVAL, {
        x: x + 0.3, y: y + 0.35, w: 0.85, h: 0.85,
        fill: { color: BG }, line: { color: BORDER, width: 0.5 },
      });
      slide.addImage({ data: it.ic, x: x + 0.49, y: y + 0.54, w: 0.47, h: 0.47 });

      slide.addText(it.title, {
        x: x + 1.3, y: y + 0.22, w: cardW - 1.4, h: 0.42,
        fontSize: 16, fontFace: "Calibri", color: NAVY, bold: true, margin: 0,
      });
      slide.addText(it.text, {
        x: x + 1.3, y: y + 0.65, w: cardW - 1.4, h: 0.85,
        fontSize: 11.5, fontFace: "Calibri", color: SLATE, margin: 0,
      });
    });

    addFooter(slide, 7);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 8 — Architecture (MVVM)
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Architecture · MVVM", "07 · Code organization");

    const layers = [
      { title: "View", desc: "Flutter widgets (Scaffold, ListView, …). Listen to ViewModels, never touch repos.", color: BRAND },
      { title: "ViewModel", desc: "ChangeNotifier classes that hold UI state, validate inputs, and call repositories.", color: BRAND_DARK },
      { title: "Repository", desc: "Firestore & Firebase Auth wrappers. Maps documents into model classes.", color: ACCENT_PURPLE },
      { title: "Model", desc: "Plain data classes (User, Transaction, Goal, Categorie, UserSettings, …).", color: NAVY },
    ];

    const stackX = 0.7, stackY = 2.0, layerW = 5.4, layerH = 0.95;
    layers.forEach((l, i) => {
      const y = stackY + i * (layerH + 0.12);
      slide.addShape(pres.shapes.RECTANGLE, {
        x: stackX, y, w: layerW, h: layerH,
        fill: { color: l.color }, line: { type: "none" },
        shadow: makeShadow(),
      });
      slide.addText(l.title, {
        x: stackX + 0.3, y: y + 0.12, w: 2, h: 0.4,
        fontSize: 18, fontFace: "Georgia", color: "FFFFFF", bold: true, margin: 0,
      });
      slide.addText(l.desc, {
        x: stackX + 0.3, y: y + 0.5, w: layerW - 0.4, h: 0.5,
        fontSize: 10.5, fontFace: "Calibri", color: "F8FAFC", margin: 0,
      });
    });

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 6.7, y: 2.0, w: 6.0, h: 4.55,
      fill: { color: "0F172A" }, line: { type: "none" },
    });
    slide.addText("lib/", {
      x: 6.95, y: 2.15, w: 4, h: 0.35,
      fontSize: 13, fontFace: "Consolas", color: BRAND, bold: true, margin: 0,
    });
    slide.addText([
      { text: "├── Model/            // data classes", options: { breakLine: true } },
      { text: "├── Repository/       // Firestore + Auth", options: { breakLine: true } },
      { text: "├── viewModel/        // ChangeNotifier", options: { breakLine: true } },
      { text: "├── view/             // pages & widgets", options: { breakLine: true } },
      { text: "│    └── widgets/     // shared UI", options: { breakLine: true } },
      { text: "├── util/             // theme, i18n, observer", options: { breakLine: true } },
      { text: "├── helper/           // enums", options: { breakLine: true } },
      { text: "└── main.dart         // app entry point", options: {} },
    ], {
      x: 6.95, y: 2.55, w: 5.7, h: 3.9,
      fontSize: 12, fontFace: "Consolas", color: "E2E8F0", margin: 0,
      paraSpaceAfter: 4,
    });

    addFooter(slide, 8);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 9 — Database Connectivity
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Database Connectivity", "08 · Cloud Firestore");

    slide.addText(
      "Each model class has a dedicated repository that talks to a single " +
      "Firestore collection. Repositories convert documents to typed Dart objects, " +
      "so view-models never see raw maps.",
      {
        x: 0.7, y: 1.85, w: 12, h: 0.7,
        fontSize: 13, fontFace: "Calibri", color: SLATE, margin: 0,
      }
    );

    const headerStyle = { bold: true, color: "FFFFFF", fill: { color: BRAND } };
    const tableData = [
      [
        { text: "Collection", options: headerStyle },
        { text: "Model", options: headerStyle },
        { text: "Repository", options: headerStyle },
        { text: "Key fields", options: headerStyle },
      ],
      ["users", "User", "UserRepository", "userID, firstName, lastName, email"],
      ["transactions", "Transaction", "TransactionRepository", "type, amount, date, categoryID, goalID?"],
      ["categories", "Categorie", "CategorieRepository", "categoryName, type"],
      ["budgets", "Budget", "BudgetRepository", "budgetName, amount, period, categoryID"],
      ["goals", "Goal", "GoalRepository", "goalName, goalAmount, currentAmount, targetDate"],
      ["userSettings", "UserSettings", "UserSettingsRepository", "darkMode, twoFactorEnabled, language"],
    ].map((row, i) => {
      if (i === 0) return row;
      return row.map((c) => ({ text: c, options: { color: NAVY, fontSize: 11 } }));
    });

    slide.addTable(tableData, {
      x: 0.7, y: 2.75, w: 12,
      colW: [1.8, 2.3, 3.4, 4.5],
      rowH: 0.45,
      fontFace: "Calibri",
      fontSize: 12,
      border: { type: "solid", pt: 0.5, color: BORDER },
      align: "left",
      valign: "middle",
    });

    slide.addText(
      "Connection: Firebase is initialised once in main.dart via Firebase.initializeApp(). " +
      "Repositories then use the singleton FirebaseFirestore.instance for all reads and writes.",
      {
        x: 0.7, y: 5.95, w: 12, h: 0.8,
        fontSize: 11.5, fontFace: "Calibri", color: SLATE, italic: true, margin: 0,
      }
    );

    addFooter(slide, 9);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 10 — API Calls
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "API Calls", "09 · Firebase service surface");

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.7, y: 1.85, w: 6.0, h: 4.9,
      fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
      shadow: makeShadow(),
    });
    slide.addImage({ data: icLock, x: 0.95, y: 2.05, w: 0.38, h: 0.38 });
    slide.addText("Firebase Authentication", {
      x: 1.45, y: 2.0, w: 5, h: 0.45,
      fontSize: 17, fontFace: "Georgia", color: NAVY, bold: true, margin: 0,
    });
    slide.addText([
      { text: "createUserWithEmailAndPassword()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Registers a new account during sign-up.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "signInWithEmailAndPassword()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Authenticates a returning user on login.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "sendEmailVerification()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Sends the verification link after sign-up.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "sendPasswordResetEmail()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Triggers the password-reset email flow.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "verifyBeforeUpdateEmail()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Validates the new email before applying it.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "signOut()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Ends the user session.", options: { color: SLATE, fontSize: 11 } },
    ], {
      x: 0.95, y: 2.55, w: 5.55, h: 4.0,
      fontSize: 12, fontFace: "Calibri", margin: 0,
      paraSpaceAfter: 2,
    });

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 6.95, y: 1.85, w: 5.75, h: 4.9,
      fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
      shadow: makeShadow(),
    });
    slide.addImage({ data: icDb, x: 7.2, y: 2.05, w: 0.38, h: 0.38 });
    slide.addText("Cloud Firestore", {
      x: 7.7, y: 2.0, w: 5, h: 0.45,
      fontSize: 17, fontFace: "Georgia", color: NAVY, bold: true, margin: 0,
    });
    slide.addText([
      { text: "collection().add() / .set()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Creates a new document for a record.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "doc().get()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Fetches a single record by ID.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "collection().where().orderBy().get()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Queries transactions, goals, and budgets per user.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "doc().update()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Updates fields (goal progress, settings).", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "doc().delete()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Removes a transaction, goal, or member.", options: { breakLine: true, color: SLATE, fontSize: 11 } },
      { text: " ", options: { breakLine: true, fontSize: 6 } },
      { text: "snapshots()", options: { fontFace: "Consolas", color: BRAND, breakLine: true, bold: true } },
      { text: "Streams live updates when used (e.g. shared expenses).", options: { color: SLATE, fontSize: 11 } },
    ], {
      x: 7.2, y: 2.55, w: 5.3, h: 4.0,
      fontSize: 12, fontFace: "Calibri", margin: 0,
      paraSpaceAfter: 2,
    });

    addFooter(slide, 10);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 11 — User Stories (Part 1)
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "User Stories", "10 · From the user's perspective");

    const stories = [
      {
        text: "As a new user, I want to sign up with my email and password so that I can start tracking my finances.",
        ac: "Verification email is sent automatically; user lands on the verification screen.",
      },
      {
        text: "As a returning user, I want to log in with my saved credentials so that I can quickly access my dashboard.",
        ac: "Login persists across app restarts; dark mode and language reload from Firestore.",
      },
      {
        text: "As a user, I want to add a new transaction so that my expenses and income are recorded.",
        ac: "Form supports type, amount, category, date, and optional goal link.",
      },
      {
        text: "As a user, I want to filter and sort my transaction history so that I can analyze my spending habits.",
        ac: "Filters: type, date range. Sorting: newest, oldest, highest, lowest.",
      },
    ];

    stories.forEach((s, i) => {
      const y = 1.85 + i * 1.18;
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 12, h: 1.05,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
      });
      // Brand-coloured left strip as a small accent in place of the ID badge
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 0.12, h: 1.05,
        fill: { color: BRAND }, line: { type: "none" },
      });
      slide.addText(s.text, {
        x: 1.05, y: y + 0.1, w: 11.5, h: 0.5,
        fontSize: 13, fontFace: "Calibri", color: NAVY, margin: 0,
      });
      slide.addText([
        { text: "Acceptance: ", options: { bold: true, color: BRAND } },
        { text: s.ac, options: { color: SLATE } },
      ], {
        x: 1.05, y: y + 0.62, w: 11.5, h: 0.4,
        fontSize: 11, fontFace: "Calibri", italic: true, margin: 0,
      });
    });

    addFooter(slide, 11);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 12 — User Stories (Part 2)
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "User Stories (cont.)", "10 · From the user's perspective");

    const stories = [
      {
        text: "As a user, I want to set financial goals so that I can save towards a target.",
        ac: "Goals carry name, amount, current progress, and target date.",
      },
      {
        text: "As a user, I want contributions to a goal to be recorded as transactions so my history stays consistent.",
        ac: "A transfer transaction in the Savings category is auto-created on each contribution.",
      },
      {
        text: "As a user, I want to switch the app to my preferred language so I can read the UI in my native tongue.",
        ac: "7 languages supported; selection persists across sessions.",
      },
      {
        text: "As a user, I want to enable dark mode so the app is easier on my eyes at night.",
        ac: "Toggle in Settings; theme flips instantly and persists for the account.",
      },
    ];

    stories.forEach((s, i) => {
      const y = 1.85 + i * 1.18;
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 12, h: 1.05,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
      });
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 0.7, y, w: 0.12, h: 1.05,
        fill: { color: BRAND }, line: { type: "none" },
      });
      slide.addText(s.text, {
        x: 1.05, y: y + 0.1, w: 11.5, h: 0.5,
        fontSize: 13, fontFace: "Calibri", color: NAVY, margin: 0,
      });
      slide.addText([
        { text: "Acceptance: ", options: { bold: true, color: BRAND } },
        { text: s.ac, options: { color: SLATE } },
      ], {
        x: 1.05, y: y + 0.62, w: 11.5, h: 0.4,
        fontSize: 11, fontFace: "Calibri", italic: true, margin: 0,
      });
    });

    addFooter(slide, 12);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 13 — Test Cases
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Test Cases", "11 · Manual validation");

    const headerStyle = { bold: true, color: "FFFFFF", fill: { color: BRAND }, fontSize: 11 };
    const tableData = [
      [
        { text: "Scenario", options: headerStyle },
        { text: "Expected Result", options: headerStyle },
        { text: "Status", options: headerStyle },
      ],
      ["Sign up with a new email", "Account created, verification email sent", "Pass"],
      ["Sign in with valid credentials", "User reaches Home dashboard", "Pass"],
      ["Sign in with wrong password", "Friendly error displayed", "Pass"],
      ["Reset password from Forgot screen", "Reset email arrives within 1 min", "Pass"],
      ["Add a transaction (expense)", "Appears in History; balance updates", "Pass"],
      ["Filter History by date range", "List narrows to matching dates only", "Pass"],
      ["Add positive goal contribution", "Goal grows; transaction auto-created", "Pass"],
      ["Decrease goal — Withdrawal", "Withdrawal logged as transfer", "Pass"],
      ["Decrease goal — Correction", "Silent update, no transaction added", "Pass"],
      ["Toggle dark mode", "Whole app re-themes instantly", "Pass"],
      ["Switch language to Vietnamese", "All visible strings translate", "Pass"],
      ["Log out and back in", "Theme & language re-load from cloud", "Pass"],
    ].map((row, i) => {
      if (i === 0) return row;
      const statusColor =
        row[2] === "Pass" ? ACCENT_GREEN :
        row[2] === "Fail" ? ACCENT_RED : MUTED;
      return [
        { text: row[0], options: { color: NAVY, fontSize: 11 } },
        { text: row[1], options: { color: SLATE, fontSize: 11 } },
        { text: row[2], options: { color: statusColor, bold: true, fontSize: 11, align: "center" } },
      ];
    });

    slide.addTable(tableData, {
      x: 0.7, y: 1.85, w: 12,
      colW: [4.6, 5.7, 1.7],
      rowH: 0.35,
      fontFace: "Calibri",
      border: { type: "solid", pt: 0.5, color: BORDER },
      valign: "middle",
    });

    addFooter(slide, 13);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 14 — Roles · The Vinh Vuong
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Roles & Responsibilities · Vinh", "12 · Individual contributions");

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.7, y: 1.85, w: 3.8, h: 4.9,
      fill: { color: "0B1437" }, line: { type: "none" },
    });
    slide.addShape(pres.shapes.OVAL, {
      x: 1.45, y: 2.3, w: 2.3, h: 2.3,
      fill: { color: BRAND }, line: { type: "none" },
    });
    slide.addImage({ data: icUser, x: 1.95, y: 2.8, w: 1.3, h: 1.3 });
    slide.addText("The Vinh Vuong", {
      x: 0.7, y: 4.85, w: 3.8, h: 0.45,
      fontSize: 20, fontFace: "Georgia", color: "FFFFFF", bold: true,
      align: "center", margin: 0,
    });
    slide.addText("Full-Stack Developer", {
      x: 0.7, y: 5.3, w: 3.8, h: 0.35,
      fontSize: 12, fontFace: "Calibri", color: BRAND, bold: true,
      align: "center", charSpacing: 3, margin: 0,
    });
    slide.addText("vuongthevinh07@gmail.com", {
      x: 0.7, y: 5.7, w: 3.8, h: 0.35,
      fontSize: 11, fontFace: "Calibri", color: "CBD5E1",
      align: "center", margin: 0,
    });

    slide.addText("KEY CONTRIBUTIONS", {
      x: 4.85, y: 1.85, w: 8, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: BRAND, bold: true,
      charSpacing: 4, margin: 0,
    });
    slide.addText([
      { text: "Authentication & account flows", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "Login, sign-up, email verification, password reset, and 2FA placeholder page.", options: { color: SLATE, fontSize: 11.5, breakLine: true } },
      { text: " ", options: { breakLine: true, fontSize: 4 } },
      { text: "Transaction History & Add Transaction", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "Full History page with filter/sort/date sheets and the modal Add-Transaction form (auto-goal linking).", options: { color: SLATE, fontSize: 11.5, breakLine: true } },
      { text: " ", options: { breakLine: true, fontSize: 4 } },
      { text: "Goals module + contribution logic", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "Goal creation, progress sheet, and the contribution/withdrawal flow that auto-logs transfer transactions in the Savings category.", options: { color: SLATE, fontSize: 11.5, breakLine: true } },
      { text: " ", options: { breakLine: true, fontSize: 4 } },
      { text: "Profile & Settings — Dark mode, Edit profile, Change password", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "Centralized ThemeController + AppTheme so any page can flip light/dark via Theme.of(context).", options: { color: SLATE, fontSize: 11.5, breakLine: true } },
      { text: " ", options: { breakLine: true, fontSize: 4 } },
      { text: "Localization — 5 additional languages", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "Added Spanish, German, Chinese, Japanese, and Vietnamese to the localization registry built around English & French.", options: { color: SLATE, fontSize: 11.5, breakLine: true } },
      { text: " ", options: { breakLine: true, fontSize: 4 } },
      { text: "Shared infrastructure", options: { bold: true, color: NAVY, breakLine: true } },
      { text: "AppBottomNavBar widget, RouteObserver, Firestore data modelling for User/Transaction/Goal/Categorie/UserSettings.", options: { color: SLATE, fontSize: 11.5 } },
    ], {
      x: 4.85, y: 2.2, w: 7.85, h: 4.5,
      fontSize: 13, fontFace: "Calibri", margin: 0,
      paraSpaceAfter: 2,
    });

    addFooter(slide, 14);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 15 — Roles · James Luciano (placeholder)
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Roles & Responsibilities · James", "13 · Individual contributions");

    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.7, y: 1.85, w: 3.8, h: 4.9,
      fill: { color: "0B1437" }, line: { type: "none" },
    });
    slide.addShape(pres.shapes.OVAL, {
      x: 1.45, y: 2.3, w: 2.3, h: 2.3,
      fill: { color: BRAND }, line: { type: "none" },
    });
    slide.addImage({ data: icUser, x: 1.95, y: 2.8, w: 1.3, h: 1.3 });
    slide.addText("James Luciano", {
      x: 0.7, y: 4.85, w: 3.8, h: 0.45,
      fontSize: 20, fontFace: "Georgia", color: "FFFFFF", bold: true,
      align: "center", margin: 0,
    });
    slide.addText("Full-Stack Developer", {
      x: 0.7, y: 5.3, w: 3.8, h: 0.35,
      fontSize: 12, fontFace: "Calibri", color: BRAND, bold: true,
      align: "center", charSpacing: 3, margin: 0,
    });
    slide.addText("[ contact info ]", {
      x: 0.7, y: 5.7, w: 3.8, h: 0.35,
      fontSize: 11, fontFace: "Calibri", color: "94A3B8", italic: true,
      align: "center", margin: 0,
    });

    slide.addText("KEY CONTRIBUTIONS", {
      x: 4.85, y: 1.85, w: 8, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: BRAND, bold: true,
      charSpacing: 4, margin: 0,
    });

    const placeholders = [
      "Add module / feature 1",
      "Add module / feature 2",
      "Add module / feature 3",
      "Base localization — English & French",
      "Add module / feature 4",
      "Add module / feature 5",
    ];
    placeholders.forEach((p, i) => {
      const y = 2.25 + i * 0.7;
      slide.addShape(pres.shapes.RECTANGLE, {
        x: 4.85, y, w: 7.85, h: 0.55,
        fill: { color: BG },
        line: { color: MUTED, width: 0.75, dashType: p.startsWith("Base") ? "solid" : "dash" },
      });
      slide.addText(p, {
        x: 5.05, y, w: 7.45, h: 0.55,
        fontSize: 13, fontFace: "Calibri",
        color: p.startsWith("Base") ? NAVY : MUTED,
        bold: p.startsWith("Base"),
        italic: !p.startsWith("Base"),
        valign: "middle", margin: 0,
      });
    });

    slide.addText("» Replace the dashed placeholders with your actual contributions «", {
      x: 4.85, y: 6.55, w: 7.85, h: 0.3,
      fontSize: 10, fontFace: "Calibri", color: MUTED, italic: true,
      align: "right", margin: 0,
    });

    addFooter(slide, 15);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 16 — Process & Lessons Learned
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: CARD };
    addContentTitle(slide, "Process & Lessons Learned", "14 · Reflections");

    const steps = [
      { num: "01", title: "Plan & Prototype", text: "Defined scope, sketched mockups, agreed MVVM split.", ic: icBook },
      { num: "02", title: "Build & Integrate", text: "Authored screens, connected Firebase, divided modules.", ic: icCode },
      { num: "03", title: "Test & Polish", text: "Manual test pass, dark-mode pass, full localization pass.", ic: icCheck },
    ];
    steps.forEach((s, i) => {
      const x = 0.7 + i * 4.15;
      slide.addShape(pres.shapes.RECTANGLE, {
        x, y: 1.95, w: 3.95, h: 2.2,
        fill: { color: CARD }, line: { color: BORDER, width: 0.75 },
        shadow: makeShadow(),
      });
      slide.addText(s.num, {
        x: x + 0.25, y: 2.05, w: 1.2, h: 0.5,
        fontSize: 32, fontFace: "Georgia", color: BRAND, bold: true, margin: 0,
      });
      slide.addImage({ data: s.ic, x: x + 3.25, y: 2.15, w: 0.42, h: 0.42 });
      slide.addText(s.title, {
        x: x + 0.25, y: 2.7, w: 3.5, h: 0.4,
        fontSize: 17, fontFace: "Calibri", color: NAVY, bold: true, margin: 0,
      });
      slide.addText(s.text, {
        x: x + 0.25, y: 3.15, w: 3.5, h: 0.9,
        fontSize: 11.5, fontFace: "Calibri", color: SLATE, margin: 0,
      });
    });

    slide.addText("KEY TAKEAWAYS", {
      x: 0.7, y: 4.5, w: 8, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: BRAND, bold: true,
      charSpacing: 4, margin: 0,
    });
    slide.addText([
      { text: "Centralizing theme & navigation early saved time across every later screen.", options: { bullet: true, breakLine: true } },
      { text: "Treating goal contributions as real transactions kept the data model honest and auditable.", options: { bullet: true, breakLine: true } },
      { text: "A simple Map-based localization registry scaled cleanly from 2 -> 7 languages.", options: { bullet: true, breakLine: true } },
      { text: "Pinning Firebase package versions avoided Pigeon channel mismatches on Android.", options: { bullet: true } },
    ], {
      x: 0.7, y: 4.85, w: 12, h: 2.0,
      fontSize: 13, fontFace: "Calibri", color: NAVY,
      paraSpaceAfter: 4, margin: 0,
    });

    addFooter(slide, 16);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SLIDE 17 — Thank You / Closing
  // ════════════════════════════════════════════════════════════════════════════
  {
    const slide = pres.addSlide();
    slide.background = { color: "0B1437" };

    slide.addShape(pres.shapes.OVAL, {
      x: -2.0, y: SLIDE_H - 3.5, w: 5.5, h: 5.5,
      fill: { color: BRAND, transparency: 80 }, line: { type: "none" },
    });
    slide.addShape(pres.shapes.OVAL, {
      x: SLIDE_W - 3.5, y: -1.5, w: 5.0, h: 5.0,
      fill: { color: BRAND_DARK, transparency: 85 }, line: { type: "none" },
    });

    slide.addText("Thank you", {
      x: 0.9, y: 2.2, w: 11, h: 1.4,
      fontSize: 80, fontFace: "Georgia", color: "FFFFFF", bold: true, margin: 0,
    });
    slide.addShape(pres.shapes.RECTANGLE, {
      x: 0.9, y: 3.7, w: 0.9, h: 0.04,
      fill: { color: BRAND }, line: { type: "none" },
    });
    slide.addText("Questions, comments, or live demo welcome.", {
      x: 0.9, y: 3.9, w: 11, h: 0.6,
      fontSize: 20, fontFace: "Calibri", color: "CBD5E1", italic: true, margin: 0,
    });

    slide.addText([
      { text: "The Vinh Vuong   ·   ", options: { color: "FFFFFF", bold: true } },
      { text: "James Luciano", options: { color: "FFFFFF", bold: true } },
    ], {
      x: 0.9, y: SLIDE_H - 1.0, w: 12, h: 0.4,
      fontSize: 14, fontFace: "Calibri", margin: 0,
    });
    slide.addText("JATV Finance Tracker  ·  May 17, 2026", {
      x: 0.9, y: SLIDE_H - 0.6, w: 12, h: 0.3,
      fontSize: 11, fontFace: "Calibri", color: MUTED, charSpacing: 3, margin: 0,
    });
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  await pres.writeFile({ fileName: "Final-Project-Report.pptx" });
  console.log("Final-Project-Report.pptx written");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
