# Example usage:

If you just want to also compile diagrams as part of your normal post
displaying, you just need the function `pandocCompilerDiagrams`).

Here's how I've included it:

```
match "posts/*" $ do
    route $ setExtension "html"
    compile $ 
            (pandocCompilerDiagrams "images/diagrams" <|> pandocMathCompiler)
        >>= loadAndApplyTemplate "templates/post.html"    postCtx
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls
```
