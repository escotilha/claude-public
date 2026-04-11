"""
Visual Generator for Portfolio Reporter

Uses Google Gemini 2.5 Flash Image (Nano Banana) to generate custom
visuals for portfolio presentation slides.
"""

import os
import base64
import hashlib
from typing import Optional, Dict, List
from pathlib import Path

# Try new google.genai package first
try:
    from google import genai
    from google.genai import types
    NEW_GENAI_AVAILABLE = True
except ImportError:
    NEW_GENAI_AVAILABLE = False

# Fallback to old package
try:
    import google.generativeai as old_genai
    OLD_GENAI_AVAILABLE = True
except ImportError:
    OLD_GENAI_AVAILABLE = False


def _load_gemini_key_from_global_config() -> Optional[str]:
    """Load GEMINI_API_KEY from global config file if not in environment."""
    global_config = Path.home() / "Library/Mobile Documents/com~apple~CloudDocs/Config/.env"
    if global_config.exists():
        try:
            for line in global_config.read_text().splitlines():
                if line.startswith("GEMINI_API_KEY="):
                    return line.split("=", 1)[1].strip()
        except:
            pass
    return None


class GeminiVisualGenerator:
    """
    Generate custom visuals for portfolio presentations using Gemini.
    Uses gemini-2.5-flash-image (Nano Banana) for image generation.
    """

    # Model for image generation (Nano Banana)
    IMAGE_MODEL = "gemini-2.5-flash-image"

    # Nuvini brand colors
    BRAND_COLORS = {
        "primary": "#1B4F8C",    # Navy blue
        "accent": "#00A19C",     # Teal
        "highlight": "#FF8C42",  # Orange
        "success": "#10B981",    # Green
        "background": "#F8FAFC"  # Light gray
    }

    def __init__(self, api_key: Optional[str] = None, cache_dir: Optional[Path] = None):
        """
        Initialize the visual generator.

        Args:
            api_key: Gemini API key (defaults to GEMINI_API_KEY env var or global config)
            cache_dir: Directory for caching generated images
        """
        self.api_key = (
            api_key or
            os.environ.get("GEMINI_API_KEY") or
            os.environ.get("GOOGLE_API_KEY") or
            _load_gemini_key_from_global_config()
        )

        self.client = None
        self.use_new_api = False
        self._initialized = False

        # Cache directory
        self.cache_dir = cache_dir or Path("cache/visuals")
        self.cache_dir.mkdir(parents=True, exist_ok=True)

        if self.api_key:
            self._initialize_client()

    def _initialize_client(self):
        """Initialize the Gemini client"""
        if self._initialized:
            return

        # Try new API first
        if NEW_GENAI_AVAILABLE:
            try:
                self.client = genai.Client(api_key=self.api_key)
                self.use_new_api = True
                self._initialized = True
                return
            except Exception as e:
                print(f"[VisualGen] New API init failed: {e}")

        # Fallback to old API
        if OLD_GENAI_AVAILABLE:
            try:
                old_genai.configure(api_key=self.api_key)
                self.client = old_genai.GenerativeModel("gemini-2.0-flash-exp")
                self.use_new_api = False
                self._initialized = True
            except Exception as e:
                print(f"[VisualGen] Old API init failed: {e}")

    @property
    def is_available(self) -> bool:
        """Check if image generation is available"""
        return self.client is not None and self._initialized

    def generate_image(self, prompt: str, image_type: str = "general") -> Optional[bytes]:
        """
        Generate an image from a prompt.

        Args:
            prompt: The image generation prompt
            image_type: Type of image for caching purposes

        Returns:
            Image bytes or None if failed
        """
        if not self.is_available:
            return None

        # Check cache first
        cache_key = self._get_cache_key(prompt)
        cached = self._load_from_cache(cache_key)
        if cached:
            return cached

        try:
            if self.use_new_api:
                image_data = self._generate_new_api(prompt)
            else:
                image_data = self._generate_old_api(prompt)

            if image_data:
                self._save_to_cache(cache_key, image_data)
                return image_data

        except Exception as e:
            print(f"[VisualGen] Generation error: {e}")

        return None

    def _generate_new_api(self, prompt: str) -> Optional[bytes]:
        """Generate image using new google.genai API"""
        try:
            response = self.client.models.generate_content(
                model=self.IMAGE_MODEL,
                contents=[prompt],
                config=types.GenerateContentConfig(
                    response_modalities=['Image'],
                )
            )

            for part in response.candidates[0].content.parts:
                if hasattr(part, 'inline_data') and part.inline_data:
                    image_data = part.inline_data.data
                    if isinstance(image_data, bytes):
                        return image_data
                    else:
                        return base64.b64decode(image_data)

        except Exception as e:
            print(f"[VisualGen] New API error: {e}")

        return None

    def _generate_old_api(self, prompt: str) -> Optional[bytes]:
        """Generate image using old google.generativeai API"""
        try:
            response = self.client.generate_content(prompt)

            if hasattr(response, 'candidates') and response.candidates:
                for candidate in response.candidates:
                    if hasattr(candidate, 'content') and candidate.content.parts:
                        for part in candidate.content.parts:
                            if hasattr(part, 'inline_data') and part.inline_data:
                                image_data = part.inline_data.data
                                if isinstance(image_data, bytes):
                                    return image_data
                                else:
                                    return base64.b64decode(image_data)

        except Exception as e:
            print(f"[VisualGen] Old API error: {e}")

        return None

    def _get_cache_key(self, prompt: str) -> str:
        """Generate cache key from prompt"""
        return hashlib.md5(prompt.encode()).hexdigest()[:16]

    def _load_from_cache(self, cache_key: str) -> Optional[bytes]:
        """Load image from cache"""
        cache_file = self.cache_dir / f"{cache_key}.png"
        if cache_file.exists():
            try:
                return cache_file.read_bytes()
            except:
                pass
        return None

    def _save_to_cache(self, cache_key: str, image_data: bytes):
        """Save image to cache"""
        try:
            cache_file = self.cache_dir / f"{cache_key}.png"
            cache_file.write_bytes(image_data)
        except Exception as e:
            print(f"[VisualGen] Cache save error: {e}")

    # Portfolio-specific image generators

    def generate_title_visual(self, period: str, company_count: int) -> Optional[bytes]:
        """Generate visual for title slide"""
        prompt = f"""Generate a professional corporate header image for a portfolio financial report.

Theme: Investment portfolio, financial performance, {company_count} companies
Period: {period}

Style: Modern, professional, suitable for executive presentations
Colors: Navy blue (#1B4F8C), teal (#00A19C), white

Requirements:
- Abstract, professional business imagery
- Clean, minimalist design with geometric elements
- Conveys growth, success, and portfolio diversification
- NO text, NO logos, NO faces
- Wide banner format (3:1 aspect ratio)
- High quality, polished corporate aesthetic"""

        return self.generate_image(prompt, "title")

    def generate_performance_visual(
        self,
        total_revenue: float,
        ebitda_margin: float,
        growth_direction: str = "positive"
    ) -> Optional[bytes]:
        """Generate visual for performance overview"""
        direction = "upward, growth" if growth_direction == "positive" else "stable, recovery"

        prompt = f"""Generate a professional financial performance visualization.

Theme: Portfolio performance, EBITDA margin {ebitda_margin:.1f}%
Direction: {direction}

Style: Clean infographic, data visualization
Colors: Navy (#1B4F8C), teal (#00A19C), green (#10B981)

Requirements:
- Abstract representation of financial performance
- {direction} trending visual elements
- Modern chart/graph aesthetic without specific numbers
- Professional, corporate aesthetic
- 16:9 aspect ratio
- NO text"""

        return self.generate_image(prompt, "performance")

    def generate_company_grid_visual(self, companies: List[str]) -> Optional[bytes]:
        """Generate visual representing portfolio companies"""
        company_count = len(companies)

        prompt = f"""Generate a professional portfolio composition visualization.

Theme: {company_count} SaaS/software companies in a portfolio
Companies represent: Technology, B2B, subscription business models

Style: Modern grid/mosaic layout
Colors: Navy (#1B4F8C), teal (#00A19C), orange (#FF8C42)

Requirements:
- Abstract representation of {company_count} connected entities
- Grid or constellation pattern showing portfolio structure
- Interconnected nodes representing synergies
- Professional, corporate aesthetic
- 16:9 aspect ratio
- NO text, NO logos"""

        return self.generate_image(prompt, "companies")

    def generate_growth_visual(self, mom_change: float) -> Optional[bytes]:
        """Generate visual for growth trends"""
        if mom_change >= 0:
            direction = "upward growth, momentum"
            color_emphasis = "green (#10B981)"
        else:
            direction = "stabilization, recovery"
            color_emphasis = "orange (#FF8C42)"

        prompt = f"""Generate a professional growth trend visualization.

Theme: Month-over-month performance change
Direction: {direction}

Style: Modern trend visualization
Colors: Primary navy (#1B4F8C), {color_emphasis}

Requirements:
- Dynamic, directional visual elements
- Abstract representation of {direction}
- Flow or wave patterns
- Professional, corporate aesthetic
- 16:9 aspect ratio
- NO text, NO specific numbers"""

        return self.generate_image(prompt, "growth")

    def generate_summary_visual(
        self,
        companies_count: int,
        positive_companies: int,
        ebitda_positive: bool
    ) -> Optional[bytes]:
        """Generate visual for summary/conclusion slide"""
        sentiment = "strong, successful" if positive_companies > companies_count / 2 else "steady, developing"

        prompt = f"""Generate a professional portfolio summary visualization.

Theme: {companies_count} company portfolio, {sentiment} performance
Sentiment: {sentiment}

Style: Corporate conclusion, achievement
Colors: Navy (#1B4F8C), gold/orange (#FF8C42), teal (#00A19C)

Requirements:
- Abstract representation of portfolio success
- Forward-looking, optimistic imagery
- Professional achievement concept
- Suitable for executive presentation
- 16:9 aspect ratio
- NO text"""

        return self.generate_image(prompt, "summary")

    def generate_all_visuals(
        self,
        period: str,
        companies: List[str],
        total_revenue: float,
        ebitda_margin: float,
        mom_change: float
    ) -> Dict[str, Optional[bytes]]:
        """
        Generate all visuals for a portfolio presentation.

        Returns dict mapping visual type to image bytes.
        """
        visuals = {}

        company_count = len(companies)
        positive_companies = company_count // 2 + 1  # Simplified estimate

        visuals["title"] = self.generate_title_visual(period, company_count)
        visuals["performance"] = self.generate_performance_visual(
            total_revenue,
            ebitda_margin,
            "positive" if mom_change >= 0 else "negative"
        )
        visuals["companies"] = self.generate_company_grid_visual(companies)
        visuals["growth"] = self.generate_growth_visual(mom_change)
        visuals["summary"] = self.generate_summary_visual(
            company_count,
            positive_companies,
            ebitda_margin > 0
        )

        generated = sum(1 for v in visuals.values() if v is not None)
        print(f"[VisualGen] Generated {generated}/{len(visuals)} visuals")

        return visuals


def create_placeholder_image(
    title: str,
    color: str = "#1B4F8C",
    width: int = 1280,
    height: int = 720
) -> bytes:
    """
    Create a simple SVG placeholder image.

    Returns PNG-encoded bytes (requires Pillow for conversion) or raw SVG.
    """
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:{color};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{color};stop-opacity:0.7" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad)"/>
  <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="32" fill="white" text-anchor="middle" dy=".3em">{title}</text>
</svg>'''

    return svg.encode('utf-8')


def get_visual_generator(
    api_key: Optional[str] = None,
    cache_dir: Optional[Path] = None
) -> Optional[GeminiVisualGenerator]:
    """
    Factory function to create a visual generator.

    Returns None if API key not available.
    """
    generator = GeminiVisualGenerator(api_key, cache_dir)
    if generator.is_available:
        return generator
    return None


if __name__ == "__main__":
    from dotenv import load_dotenv

    # Load .env if exists
    env_path = Path(".env")
    if env_path.exists():
        load_dotenv(env_path)

    generator = GeminiVisualGenerator()

    if generator.is_available:
        print("Testing Visual Generator...")
        print(f"API available: {generator.is_available}")

        # Test title visual
        title_img = generator.generate_title_visual("December 2025", 6)
        if title_img:
            print(f"Generated title visual: {len(title_img)} bytes")
        else:
            print("Title visual generation failed or returned placeholder")
    else:
        print("GEMINI_API_KEY not set - visual generation unavailable")
        print("To enable, set GEMINI_API_KEY environment variable")
