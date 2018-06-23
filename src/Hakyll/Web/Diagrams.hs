{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Hakyll.Web.Diagrams where

import           Safe                          (readMay)
import           System.Directory              (createDirectoryIfMissing)
import           System.FilePath
import           System.IO                     (hPutStrLn, stderr)

import qualified Codec.Picture                 as J
import           Debug.Trace
import           Diagrams.Backend.Rasterific
import qualified Diagrams.Builder              as DB
import           Diagrams.Prelude              (SizeSpec, V2, centerXY, pad,
                                                zero, (&), (.~))
import           Diagrams.TwoD.Size            (mkSizeSpec2D)
import           Hakyll
import           Hakyll.Web.Pandoc             (pandocCompilerWithTransformM)
import           System.FilePath
import           Text.Pandoc
import           Text.Pandoc.Diagrams
import           Text.Pandoc.SelfContained
import           Text.ParserCombinators.Parsec

buildMarkdown :: Rules ()
buildMarkdown = do
    match "*.md" $ do
      route idRoute
      compile $ pandocCompilerDiagrams "images"

-- | Read a page render using pandoc
pandocCompilerDiagrams :: FilePath -> Compiler (Item String)
pandocCompilerDiagrams outDir = pandocCompilerDiagramsWith outDir defaultHakyllReaderOptions defaultHakyllWriterOptions

pandocCompilerDiagramsWith :: FilePath -> ReaderOptions -> WriterOptions -> Compiler (Item String)
pandocCompilerDiagramsWith outDir ropt wopt = pandocCompilerWithTransformM ropt wopt (diagramsTransformer outDir)

diagramsTransformer :: FilePath -> Pandoc -> Compiler Pandoc
diagramsTransformer outDir pandoc = unsafeCompiler $ renderBlockDiagrams outDir pandoc

-- | Transform a blog post by looking for code blocks with class
--   @diagrams@, and replacing them with images generated by evaluating the
--   identifier @diagrams@ and rendering the resulting diagram.  In
--   addition, blocks with class @diagrams-def@ are collected (and deleted
--   from the output) and provided as additional definitions that will
--   be in scope during evaluation of all @diagrams@ blocks.
renderBlockDiagrams :: FilePath -> Pandoc -> IO Pandoc
renderBlockDiagrams outDir p = do
    let f :: Block -> IO [Block]
        f = insertDiagrams $ Opts "png" outDir "example" True 

        g :: IO [Block] -> IO Block
        g mbs = mbs >>= return . (Div nullAttr)

    bottomUpM (g . f) p
