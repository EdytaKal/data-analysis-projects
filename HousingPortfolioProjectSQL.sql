/* 
Cleaning Data in SQL Queries (Project 3)
link to youtube:
https://www.youtube.com/watch?v=8rO7ztF4NtU&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=3
*/

-------------------------------------------------------------------------------

-- Standarize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing$

Update PortfolioProject.dbo.NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing$
-- Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing$ a
JOIN PortfolioProject.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

----------------------------------------------------------------------------

-- Breaking out the Property Address into Individual Columns (Address, City).

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing$

-- Removing coma from the output after the street name
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing$


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Breaking out the Owner Address into Individual Columns (Address, City, State).

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing$


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing$


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing$
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing$

UPDATE  PortfolioProject.dbo.NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference	
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing$
)
Delete  
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing$
DROP COLUMN SaleDate
